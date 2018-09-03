#!/bin/bash

. check_params_env

DB=${2:-"nextgen"}
DB=`echo $DB | tr 'A-Z' 'a-z'`
PARAMS_DIR="/shared/oracle/setup/${ENV}"
if [ -f ${PARAMS_DIR}/${DB}.params ]; then
  PARAMS="${PARAMS_DIR}/${DB}.params"
elif [ -f ${PARAMS_DIR}/default.params ]; then
  PARAMS="${PARAMS_DIR}/default.params"
fi

. `dirname $0`/common_tools

get_nodelist "/shared/oracle/setup/${ENV}/hosts.lst"

if [ ! -f $PARAMS ]; then
  echo "Database parameters file \"$PARAMS\" is not found."
  exit 1
fi

. $PARAMS

if [ -z "$DB_TEMPLATE" ]; then
  echo "Parameter DB_TEMPLATE must be set in $PARAMS"
  exit 2
fi
if [ ! -f $DB_TEMPLATE ]; then
  echo "Database template file \"$DB_TEMPLATE\" is not found."
  exit 1
fi
if [ -z "$GLOBAL_DB_NAME" ]; then
  echo "Parameter GLOBAL_DB_NAME must be set in $PARAMS"
  exit 2
fi
if [ -z "$SID" ]; then
  echo "Parameter SID must be set in $PARAMS"
  exit 2
fi
if [ -z "$SYSDBA_PWD" ]; then
  echo "Parameter SYSDBA_PWD must be set in $PARAMS"
  exit 2
fi
if [ -z "$SYSTEM_PWD" ]; then
  echo "Parameter SYSTEM_PWD must be set in $PARAMS"
  exit 2
fi
if [ -z "$ASMSNMP_PWD" ]; then
  echo "Parameter ASMSNMP_PWD must be set in $PARAMS"
  exit 2
fi

if [ -z "$ORACLE_HOME" ]; then
  echo "Parameter ORACLE_HOME must be set in $PARAMS"
  exit 2
fi

OLD_PATH=$PATH
PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$PATH

$ORACLE_HOME/bin/dbca -silent -customCreate -createDatabase -templateName "$DB_TEMPLATE" \
  -gdbName $GLOBAL_DB_NAME \
  -adminManaged \
  -sid $SID \
  -sysPassword "$SYSDBA_PWD" \
  -systemPassword "${SYSTEM_PWD:-$SYSDBA_PWD}" \
  -emConfiguration NONE \
  -disableSecurityConfiguration ALL \
  -redoLogFileSize 256 \
  -storageType ASM -asmsnmpPassword "${ASMSNMP_PWD:-$SYSDBA_PWD}" -diskGroupName $DG_SYS -recoveryGroupName $DG_FRA \
  -nodelist "$NODELIST" \
  -databaseType MULTIPURPOSE \
  -continueOnNonFatalErrors true

PATH=$OLD_PATH
unset DB_TEMPLATE GLOBAL_DB_NAME SID SYSDBA_PWD SYSTEM_PWD ASMSNMP_PWD PARAMS OLD_PATH

