#!/bin/bash

SCHEMA=$1
DATE=`date +%Y%m%d`
MASK=`echo $SCHEMA | tr '$' '_'`_${DATE}

if [ -n "$SCHEMA" ]; then
  $ORACLE_HOME/bin/expdp \'/ as sysdba\' directory=DATAPUMP_DIR job_name=EXP_${MASK} dumpfile=${MASK}_%U.dmp logfile=${MASK}.log content=ALL reuse_dumpfiles=y cluster=N filesize=4096M schemas=$SCHEMA
fi
