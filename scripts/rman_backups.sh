#!/bin/bash

# Script to perform full and incremental RMAN backups

# Load environment variables
. /home/oracle/.bash_profile

# Include user_data
if [[ -f "/etc/reuters/user_data" ]]; then
  . "/etc/reuters/user_data"
else
  echo "user_data file is not found"
fi


# Variables
LOGFILE=/tmp/rman_backup.log
RMAN_SCRIPT=/tmp/rman_script.rman
BACKUP_DIR=/backups/rman

BACKUP_DAY=`date +%Y%m%d`

S3_BACKUP_DIR=backup_$ORACLE_SID
REGION=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}'`

CHANNELS=$((`nproc`/4))
AL_CHANNELS=`counter=0; while [ $counter -lt $CHANNELS ]; do echo "allocate channel d$counter type disk format '$BACKUP_DIR/${PRODUCT}_%d_%U_%T';" ; let counter=$counter+1; done`
REL_CHANNELS=`counter=0; while [ $counter -lt $CHANNELS ]; do echo "release channel d$counter;"; let counter=$counter+1;done`

# Backup level:
#   Saturday - FULL
#   Rest of the week - INC
DAY_OF_WEEK=`date '+%u'`

if [[ $DAY_OF_WEEK == 6 ]]; then
  BLEVEL=0
else
  BLEVEL=1
fi

# Set S3 bucket according to the environment and product
if [ "$PRODUCT" == "cortellis" ] || [ "$PRODUCT" == "pdi" ] || [ "$PRODUCT" == "trqa" ] || [ "$PRODUCT" == "datafeeds" ] || [ "$PRODUCT" == "integrity" ] || [ "$PRODUCT" == "metacore" ] ; then
	if [ "$ACCOUNT" == "dev" ] ; then
			if  [ "$REGION" == "us-west-2" ] ; then
					S3_BUCKET=cortellis-dev-oracle-shared
			else
					S3_BUCKET=cortellis-deveu-oracle-shared
			fi
	else
			if [ "$EC2_REGION" == "us-west-2" ] ; then
					S3_BUCKET=cortellis-produs-oracle-shared
			else
					S3_BUCKET=cortellis-prodeu-oracle-shared
			fi
	fi
else
	if [ "$ACCOUNT" == "dev" ] ; then
			if  [ "$REGION" == "us-west-2" ] ; then
					S3_BUCKET=editorial-devus-oracle-shared
			else
					S3_BUCKET=editorial-dev-oracle-shared
			fi
	else
			if [ "$EC2_REGION" == "us-west-2" ] ; then
					S3_BUCKET=cc-produs-oracle-shared
			else
					S3_BUCKET=cc-prodeu-oracle-shared
			fi
	fi
fi

export NLS_DATE_FORMAT="DD-MON-RR HH24:MI:SS"

# Generate RMAN script 
# Only for CORTELLIS and EDITORIAL products we'll perform full and inc backups, for the rest of the products will be a full daily backup
echo "run {" > $RMAN_SCRIPT
echo "configure device type disk backup type to compressed backupset;" >> $RMAN_SCRIPT
echo "$AL_CHANNELS" >> $RMAN_SCRIPT
if [ "$PRODUCT" == "cortellis" ] || [ "$PRODUCT" == "editorial" ] ; then
echo "backup incremental level $BLEVEL database" >> $RMAN_SCRIPT
else
echo "backup database" >> $RMAN_SCRIPT
fi
echo "current controlfile format '$BACKUP_DIR/${PRODUCT}_%d_%U_%T_cfile'" >> $RMAN_SCRIPT
echo "spfile format '$BACKUP_DIR/${PRODUCT}_%d_%U_%T_spfile'" >> $RMAN_SCRIPT
echo "plus archivelog;" >> $RMAN_SCRIPT
echo "$REL_CHANNELS"  >> $RMAN_SCRIPT
echo "crosscheck backup;" >> $RMAN_SCRIPT
echo "crosscheck archivelog all;" >> $RMAN_SCRIPT
echo "delete noprompt expired archivelog all;" >> $RMAN_SCRIPT
echo "delete noprompt expired backup;" >> $RMAN_SCRIPT
echo "delete noprompt obsolete;" >> $RMAN_SCRIPT
echo "}" >> $RMAN_SCRIPT

rman target / log=$LOGFILE cmdfile=$RMAN_SCRIPT

# Check for errors and notify them to Slack channel
grep -E 'ORA-|RMAN-' /tmp/rman_backup.log | /home/oracle/slacktee.sh -t Errors -a "danger" -e "Date and Time" "$(date)" -e "Host" "$(hostname)" -e "Database" "$ORACLE_SID"

echo "`date` -- Uploading daily RMAN backup to s3://$S3_BUCKET/$S3_BACKUP_DIR/$BACKUP_DAY" >> $LOGFILE

# Upload backup to S3 bucket
aws s3 cp $BACKUP_DIR s3://$S3_BUCKET/$S3_BACKUP_DIR/$BACKUP_DAY --include '*.$BACKUP_DAY' --recursive --only-show-errors >> $LOGFILE

if [ $? -ne 0 ]; then
	echo "`date` -- Upload to s3 failed, sending an Slack message" >> $LOGFILE
	echo 'Upload to S3 failed!' | /home/oracle/slacktee.sh -t Errors -a "warning" -e "Date and Time" "$(date)" -e "Host" "$(hostname)" -e "Database" "$ORACLE_SID"
else
	echo "`date` -- Upload to s3 completed successfully!" >> $LOGFILE
fi

exit

