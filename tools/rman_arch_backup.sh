#!/bin/bash

# The script makes archivelog backup and delete old archivelogs

lockfile=/tmp/rman_arch_backup_${ORACLE_SID}_ARCH.lck
if [[ -f $lockfile ]]; then
  echo "Lock file \"$lockfile\" is already present"
  exit 99
else
  echo $$ > $lockfile
fi

#gather some instance variables from userdata
. /etc/reuters/user_data
# Set S3 bucket according to the environment
if [[ -z $CORTELLIS_ORACLE_SHARED_S3_BUCKET ]]; then
  echo 'Cortellis shared S3 bucket is not defined in user_data'
  exit 1
fi

DISK_SIZE=${1:-800}
MOUNT_DIR=${2:-'/backups_arch'}
DEVICE_NAME=${3:-'/dev/xvdx'}

BASEDATE=`date +%Y%m%d%H`
RMAN_SCRIPT=`mktemp`
#Calculate the number of cores and prepare the script to use half of the cores for RMAN
BACKUP_DEST=$MOUNT_DIR/$BASEDATE
CORES=`cat /proc/cpuinfo  | grep processor | wc -l`
CHANNELS=$((CORES/2))
AL_CHANNELS=`counter=0; while [ $counter -lt $CHANNELS ]; do echo " allocate channel d$counter type disk format '$BACKUP_DEST/backupd$counter""_%U';" ; let counter=$counter+1; done`
REL_CHANNELS=`counter=0; while [ $counter -lt $CHANNELS ]; do echo " release channel d$counter;"; let counter=$counter+1;done`

#Get oracle OS user bash profile for Oracle environment variables (SID, etc)
. ~/bin/set_ora_env
mkdir -p /home/oracle/log
LOGFILE=/home/oracle/log/${ORACLE_SID}_ARCH_${BASEDATE}.log
RMANLOGFILE=/home/oracle/log/${ORACLE_SID}_ARCH_${BASEDATE}_RMAN.log
#some info on the current AWS instance and logging some activity

log () {
  echo "`date`: $1" | tee -a $LOGFILE
}

log "STARTING ARCHIVELOG BACKUP of $ORACLE_SID database..."

avail_zone=`GET http://169.254.169.254/latest/meta-data/placement/availability-zone`
inst_id=`GET http://169.254.169.254/latest/meta-data/instance-id`
REGION="`echo \"$avail_zone\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"

log "Region: $REGION"
log "Availability zone: $avail_zone"
log "InstanceID: $inst_id"

mount | grep -q ' $MOUNT_DIR'
if [[ $? -eq 0 ]]; then
  log '$MOUNT_DIR is already mounted'
else
  log "Creating $DISK_SIZE GB volume and mounting it on $MOUNT_DIR"
  VOL_ID=`aws --region $REGION ec2 create-volume --size $DISK_SIZE --availability-zone $avail_zone --volume-type gp2 --output text --query 'VolumeId'`
  retval=$?
  if [[ $retval -eq 0 ]]; then
    log 'Volume created successfully'
  else
    log "ERROR: CREATING VOLUME - Exit code of volume creation: $retval"
    exit $retval
  fi

  #saving volume details to log file
  log "VolumeId: $VOL_ID"
  #waiting 20sec for the volume to be ready
  sleep 20
  # assign tags to the volume
  aws --region $REGION ec2 create-tags --resources $VOL_ID --tags Key=Name,Value=cortellis.${CORTELLIS_ENVIRONMENT}.${CORTELLIS_ROLE}.backup Key=BackupTimestamp,Value=$BASEDATE

  #actually attaching the volume
  aws --region $REGION ec2 attach-volume --volume-id $VOL_ID --instance-id $inst_id --device $DEVICE_NAME
  if [[ $? -eq 0 ]]; then
    log "Volume $VOL_ID with size $DISK_SIZE attached to the current instance $inst_id"
  else
    log "Something went wrong - volume could not be attached"
    exit 2
  fi
  sleep 5

  #formatting the volume
  sudo mkfs.ext4 $DEVICE_NAME

  if [ ! -d "$MOUNT_DIR" ] ; then
    sudo mkdir $MOUNT_DIR
  fi

  #mounting the fs
  sudo mount $DEVICE_NAME $MOUNT_DIR

  #changing mount ownership
  sudo chown oracle $MOUNT_DIR
  sudo chgrp oinstall $MOUNT_DIR
fi

#preparing directory
mkdir $MOUNT_DIR/$BASEDATE
#verifying
if [[ `mount | grep "$DEVICE_NAME" | wc -l` -lt 1 ]]; then
  log 'Something went wrong. Volume not mounted. Exiting'
  exit 2
else
  log 'Volume is mounted on $MOUNT_DIR - ready to start backup'
fi

#Crosschecking and deleting expired archivelogs
rman target / << EOF
crosscheck archivelog all;
delete noprompt expired archivelog all;
delete noprompt obsolete;
EOF

# Generate RMAN script and
# Starting the backup itself

echo "run {" > $RMAN_SCRIPT
echo " configure device type disk backup type to compressed backupset;" >> $RMAN_SCRIPT
echo " configure archivelog deletion policy to backed up 2 times to disk;" >> $RMAN_SCRIPT
echo "$AL_CHANNELS" >> $RMAN_SCRIPT
echo " backup archivelog all;"  >> $RMAN_SCRIPT
echo " delete noprompt archivelog all backed up 2 times to disk;"  >> $RMAN_SCRIPT
#echo " delete noprompt obsolete;"  >> $RMAN_SCRIPT
echo "$REL_CHANNELS"  >> $RMAN_SCRIPT
echo "}" >> $RMAN_SCRIPT

rman target / log=$RMANLOGFILE cmdfile=$RMAN_SCRIPT
echo

#Now let's upload to S3!!
log "Backup finished. Copying files to S3"

aws --region $REGION s3 cp --recursive $BACKUP_DEST/ s3://$CORTELLIS_ORACLE_SHARED_S3_BUCKET/backup_${ORACLE_SID}/$BASEDATE/

log "unmounting volume and deleting it..."
sudo umount $MOUNT_DIR || ( echo "umount failed. exiting" >> $LOGFILE; exit 2 )

aws --region $REGION ec2 detach-volume --volume-id $VOL_ID --force
sleep 15
aws --region $REGION ec2 delete-volume --volume $VOL_ID

log "BACKUP FINISHED at "`date`
if [[ -f $lockfile ]]; then
  rm $lockfile
fi
