#!/bin/bash
#
# $Id: create_oracle_user.sh 6349 2015-11-10 12:30:13Z gaurav.srivastava1 $
#
# Script to create "oracle" user and related groups in according to LION standards
#
RUID=`/usr/bin/id | awk -F\( '{print $1}' | awk -F= '{print $2}'`
if [ $RUID -ne 0 ]; then
  echo "You must be logged in as user with UID as zero (e.g. root user) to run this script."
  exit 1
fi

add_group()
{
  NAME=$1
  ID=$2
  if [ `grep $NAME /etc/group` ]; then
    if [ `grep $NAME /etc/group | awk -F':' '{print($3)}'` = $ID ]; then
      echo "Group \"$NAME\" exists and have id=$ID"
    else
      groupdel $NAME
      groupadd -g $ID $NAME
    fi
  else
    groupadd -g $ID $NAME
  fi
}

uid=`/usr/bin/id -u oracle`
retval=$?
if [ $retval -eq 0 ]; then
  if [ $uid -ne 520 ]; then
    echo "User \"oracle\" exists but have incorrect uid=$uid"
    userdel -r oracle
    retval=$?
    if [ $retval -ne 0 ]; then
      exit $retval
    fi
  else
     echo 'User "oracle" exists and have correct uid=520'
  fi
fi

add_group dba 500
add_group oinstall 501

/usr/bin/id -u oracle 2>/dev/null
retval=$?
if [ $retval -ne 0 ]; then
  # Password is available on https://pwman.lstools.int.clarivate.com
  useradd -c "Oracle software owner" -g oinstall -G dba -d /home/oracle -m -u 520 -p '$6$9c0/F8da$Nl4dWs6j26BbBFJCxP7051Wmm4HjC2JKO3T06tIp8f1RV/yfOXEVCJQOo/PDfCPyFowl6DTlqKZZ4WL8IsVzz.' oracle
  retval=$?
  if [ $retval -ne 0 ]; then
    exit $retval
  fi
fi
