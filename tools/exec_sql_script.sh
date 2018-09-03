#!/bin/bash
#
#
DB_USER=`echo "$1" | tr '[:upper:]' '[:lower:]'`
FILTER=${2:-'all'}
SCRIPT=$3
ARGS=${*:4}

if [ "$FILTER" = 'all' ]; then
  FILTER='.*'
fi

[ -f ~/.workspace ] && . ~/.workspace

TOOLS_DIR=`dirname $0`
INVENTORY="$INVENTORY_DIR/db_inventory.txt"

if [ "$DB_USER" = 'system' ]; then
  DB_CONN_PREFIX='/@'
else
  DB_CONN_PREFIX="[$DB_USER]/@admin-"
fi

if [ $# -lt 1 ] ; then
  echo "Usage: $0 <db user> <regexp filter on db names [all]> <SQL-script file> [<script arguments>]"
  exit 99
fi

if [ ! -f "$INVENTORY" ]; then
  echo "Inventory file $INVENTORY is not found"
  exit 1
fi

[ -f ~/oracle-dba/tools/dba_functions ] && . ~/oracle-dba/tools/dba_functions

if [[ -n "$SCRIPT" && ( -f "$SCRIPT" || -f "$SQLPATH/$SCRIPT" ) ]]; then
  echo "Script to execute: ${SCRIPT} $ARGS"

  for db in `grep -v '^#' $INVENTORY | egrep "$FILTER"`; do
    if [ "$DB_USER" = 'sys' ]; then
      CONN="/@$db"
    else
      CONN="$DB_CONN_PREFIX$db"
    fi
    check_db_connection $db $CONN
    retval=$?
    if [ $retval -eq 0 ]; then
      if [ "$DB_USER" = 'sys' ]; then
        sp_sys $db @$SCRIPT $ARGS
      else
        echo "Connection $CONN"

        echo "== $db =="

        _DC=`echo "$db" | rev | cut -d '-' -f 1 | rev`
        _ENV=`echo "$db" | rev | cut -d '-' -f 2 | rev`
        _DB_GROUP=`echo "$db" | rev | cut -d '-' -f 3- | rev`

        _ARGS=`echo "$ARGS" | sed -r "s/\{DB_GROUP\}/\"$_DB_GROUP\"/g;s/\{ENV\}/\"$_ENV\"/g;s/\{DC\}/\"$_DC\"/g"`

        $ORACLE_HOME/bin/sqlplus -L -S <<EOFSQL
$CONN
@$SCRIPT $_ARGS
exit
EOFSQL
        echo
      fi
    fi
  done
else
  echo "Script is not found"
  exit 2
fi

unset OUTPUT CONN DB_CONN_PREFIX retval SCRIPT ARGS _DB_GROUP _ENV _DC

