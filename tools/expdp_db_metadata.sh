#!/bin/bash

DATE=`date +%Y%m%d`
MASK=METADATA_${DATE}

$ORACLE_HOME/bin/expdp \'/ as sysdba\' directory=DATAPUMP_DIR job_name=EXP_${MASK} dumpfile=${MASK}_%U.dmp logfile=${MASK}.log content=METADATA_ONLY full=Y reuse_dumpfiles=y cluster=N filesize=4096M
