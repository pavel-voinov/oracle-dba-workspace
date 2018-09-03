#!/bin/sh

# Usage: AsmCheck.sh > `hostname` 
# And upload kfed_DH.out and hostname file generated in the current directory

# 2013/10/09    kyle Heo Created

PLATFORM=`/bin/uname`
SEQ=
KFED_DH=kfed_DH.out
KFED_BK=kfed_BK.out
KFED_PL=kf.pl

if [ "${ORACLE_HOME}" = "" ] ; then
  echo "ORACLE_HOME valiable is not specified"
  exit -1
fi

if [ "${ORACLE_SID}" = "" ] ; then
  echo "ORACLE_SID valiable is not specified"
  exit -1
fi

if [ ! -d ${ORACLE_HOME} ] ; then
  echo "ORACLE_HOME is not a valid directory"
  exit -1
fi

KFED=$ORACLE_HOME/bin/kfed

if [ ! -f ${KFED} ] ; then
  echo "kfed executable is not found"
  exit -1
fi


case $PLATFORM in
Linux)
ASM_DEVICE_PATH="/dev/oracleasm/disks/* /dev/mapper/* /dev/emcpower* /dev/raw/raw* /dev/mpath/* /dev/dm-*  /dev/sd*"

SEQ=`expr $SEQ + 1`
echo $SEQ. "uname -a"
echo "-----------"
uname -a
cat /etc/*release*  2> /dev/null

SEQ=`expr $SEQ + 1`
echo
echo $SEQ. "rpm -qa |grep oracleasm"
echo "-----------"
rpm -qa |grep oracleasm

SEQ=`expr $SEQ + 1`
echo
echo $SEQ. "Raw Device information"
echo "-----------"
#raw -qa
cat /etc/sysconfig/rawdevices

SEQ=`expr $SEQ + 1`
echo
echo $SEQ. " /usr/sbin/oracleasm configure  "
echo "-----------"
/usr/sbin/oracleasm configure

SEQ=`expr $SEQ + 1`
echo
echo $SEQ. " /usr/sbin/oracleasm-discover 'ORCL:*'  "
echo "-----------"
/usr/sbin/oracleasm-discover 'ORCL:*'

SEQ=`expr $SEQ + 1`
echo
echo $SEQ. " /etc/init.d/oracleasm status "
echo "-----------"
/etc/init.d/oracleasm status

SEQ=`expr $SEQ + 1`
echo
echo $SEQ." cat /proc/partitions  "
echo "-----------"
cat /proc/partitions

#SEQ=`expr $SEQ + 1`
#echo
#echo "8. fdisk -l  "
#echo "-----------"
#fdisk -l


SEQ=`expr $SEQ + 1`
echo
echo $SEQ. " multipath -ll   "
echo "-----------"
multipath -ll  2> /dev/null


SEQ=`expr $SEQ + 1`
echo
echo $SEQ. " powermt displau dev=all  "
echo "-----------"
powermt display dev=all  2> /dev/null


;;


HP-UX|HI-UX)

ASM_DEVICE_PATH="/dev/disk/* /dev/rdisk/* "


;;


SunOS)
ASM_DEVICE_PATH="/dev/rdsk/*  "

;;

AIX)
ASM_DEVICE_PATH="/dev/rhdisk* "


;;
esac

SEQ=`expr $SEQ + 1`
echo
echo $SEQ$. " ls -l output "
echo "-----------"
ls -l $ASM_DEVICE_PATH 2> /dev/null

SEQ=`expr $SEQ + 1`
echo
echo $SEQ. " ASM disk information    "
echo "-----------"

sqlplus -s / as sysasm <<EOF
set pagesize 1000 linesize 250
set feedback off
col gn format 999
col name format a25
col au format 99999999
col state format a12
col type format a12
col total_mb format 999,999,999
col free_mb format 999,999,999
col od format 999
col compatibility format a12
col dn format 999
col mount_status format a12
col header_status format a12
col mode_status format a12
col mode format a12
col failgroup format a25
#col label format a20
col path format a50
col value format a100
select group_number gn, name, allocation_unit_size au, state, type, total_mb, free_mb, offline_disks od, compatibility from v\$asm_diskgroup;
select group_number gn,disk_number dn, mount_status, header_status,mode_status,state, total_mb, free_mb,name, failgroup, path from v\$asm_disk order by group_number, disk_number;
select inst_id, power_kfgmg, sofar_kfgmg, work_kfgmg, rate_kfgmg, time_kfgmg, file_kfgmg from x\$kfgmg;
col name format a40
select name, value from v\$parameter where name not like ('nls_%');
EXIT
EOF

#SEQ=`expr $SEQ + 1`
#echo
#echo $SEQ. " kfed output    "
#echo "-----------"

rm -rf $KFED_DH 2> /dev/null 
rm -rf $KFED_BK 2> /dev/null 
for i in `ls  $ASM_DEVICE_PATH 2> /dev/null  `
do
echo $i >> $KFED_DH
$KFED read $i >> $KFED_DH
echo $i >> $KFED_BK
$KFED read $i aun=1 blkn=254 >> $KFED_BK
done
#$KFED_PL $KFED_DH | sort -t ' ' -k 2.3

echo '                    '  1>&2
echo '**************************************** ' 1>&2
echo 'Please upload ' $KFED_DH ' & ' $KFED_BK ' & '  `hostname` in the current directory  1>&2
echo '**************************************** ' 1>&2
