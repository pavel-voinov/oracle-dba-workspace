#!/bin/bash
RUID=`/usr/bin/id | awk -F\( '{print $1}' | awk -F= '{print $2}'`
if [ $RUID -ne 0 ]; then
  echo "You must be logged in as user with UID as zero (e.g. root user) to run this script."
  exit 1
fi

. /home/oracle/.bash_profile

if [ -x $GRID_HOME/bin/crsctl ]; then
  $GRID_HOME/bin/crsctl config crs
  $GRID_HOME/bin/crsctl check crs
fi
