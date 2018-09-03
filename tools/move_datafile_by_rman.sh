#!/bin/sh
DF_NUM=$1
SRC_PATH='/s01/oradata1'
TGT_PATH='/s04/oradata1'


if [ -z "$DF_NUM" ]; then
  echo 'DF_NUM is not set'
  exit 2
fi
if [ -z "$ORACLE_DBN" ]; then
  echo 'ORACLE_DBN is not set'
  exit 2
fi

DF_NAME=`$ORACLE_HOME/bin/sqlplus -S "/ as sysdba" <<EOFSQL
set serveroutput on size unlimited heading off timing off feedback off echo off verify off newpage none scan off linesize 4000 pagesize 9999 termout on trimspool on
whenever sqlerror exit failure
SELECT file_name FROM dba_data_files WHERE file_id = $DF_NUM;
exit
EOFSQL
`
if [[ $? -ne 0 || -z "$DF_NAME" ]]; then
  echo "It's not possible to get name of datafile with id=$DF_NUM"
  exit 2
fi

DF_NEW_NAME=`echo "$DF_NAME" | sed -r "s@$SRC_PATH@$TGT_PATH@"`

if [ "$DF_NEW_NAME" == "$DF_NAME" ]; then
  echo "Datafile $DF_NUM \"$DF_NAME\" is already moved"
  exit 0
else
  echo "Datafile $DF_NUM \"$DF_NAME\" is moving to \"$DF_NEW_NAME\""
fi


$ORACLE_HOME/bin/rman target / <<EOFCMD
SQL "ALTER DATABASE DATAFILE $DF_NUM OFFLINE";
COPY DATAFILE $DF_NUM TO '$DF_NEW_NAME';
SWITCH DATAFILE $DF_NUM TO COPY;
RECOVER DATAFILE $DF_NUM;
SQL "ALTER DATABASE DATAFILE $DF_NUM ONLINE";
report schema;
EOFCMD
