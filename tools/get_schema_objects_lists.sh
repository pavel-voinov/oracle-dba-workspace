#!/bin/bash


DBS_DEFAULT="JPHARM.QA JPHARM.DEV JPHARM.BUILD JPHARM.PROD NG.QAEDC NG.QAEAGAN"
DBS=${1:-"$DBS_DEFAULT"}
DBS=`basename $DBS`
if [ "${DBS}" = '*' ]; then
  DBS=$DBS_DEFAULT
fi
DBS=`echo "$DBS" | tr '[:lower:]' '[:upper:]'`

SCHEMAS=$2
if [ "$SCHEMAS" = '*' ]; then
  unset SCHEMAS
fi

REPORTS=$3
if ( [ -z "$REPORTS" ] || [ "$REPORTS" = '*' ] ); then
  REPORTS=`cat $SQLPATH/reports/by_schema/all_reports.default`
fi

if [ -e "$HOME/.dba.env" ]; then
  . ${HOME}/.dba.env
fi

for db in `echo "$DBS"`; do
  if [ -d "${db}" ]; then
    db_=`echo "$db" | tr '.' '_'`
    CONN="SYS_${db_}"
    CONN=`eval echo \\$"$CONN"`
    echo "Generate lists of schemas objects for \"${db}\":"

    if [ ! -d "${db}/schemas" ]; then
      mkdir -p "${db}/schemas"
    fi
    if [ -z "$SCHEMAS" ]; then
      if [ ! -e "${db}/.schemas.lst" ]; then
        echo "Warning: [.schemas.lst] file is not found in \"$db\". Use all non-system schemas from database."

        $ORACLE_HOME/bin/sqlplus -S "$CONN" > ${db}/.schemas.lst <<EOFSQL
set serveroutput on size 100000 heading off timing off feedback off echo off verify off newpage none scan off linesize 4000 pagesize 9999 termout on trimspool on
SELECT username
FROM dba_users
WHERE username like nvl('$SCHEMAS', '%')
  AND not regexp_like(username, '^(SYS(|TEM|MAN)|XD(B|K)|WIRELESS|MD(SYS|DATA)|ZABBIX|SCOTT|DBSNMP|(OLAP|CTX|EXF|APPQOS|WCR|WM)SYS|ANONYMOUS|FLOWS_FILES|ORACLE_OCM|ORD(DATA|PLUGINS|SYS)|OUTLN|SI_INFORMTN_SCHEMA|DIP|XS\\\$NULL|SPATIAL_(CSW|WFS)_ADMIN_USR|OWBSYS(|_AUDIT)|TSMSYS|C\\\$MDLICHEM.*|APEX_([0-9]+|PUBLIC_USER))\$')
ORDER BY 1
/
exit
EOFSQL
      fi
      SCHEMAS=`grep -vE '^#' ${db}/.schemas.lst | sed -r '/^\s*$/d'`
    fi

    if [ -n "$CONN" ]; then
      echo "Database: \"${db}\":"
      for SCHEMA in `echo "$SCHEMAS"`; do
        echo "===================================="
        echo "= ${SCHEMA}@${db}:"
        if [ ! -d "${db}/schemas/$SCHEMA" ]; then
           mkdir -p "${db}/schemas/$SCHEMA"
        fi
        for REPORT in `echo "$REPORTS"`; do
          R="${REPORT%.*}.sql"
          if [ ! -f "$SQLPATH/reports/by_schema/${R}" ]; then
            echo "Report SQL-script $SQLPATH/reports/by_schema/${R} not found"
          else
            REPORT_OUT="${REPORT%.*}.lst"

            echo -n "  - $REPORT_OUT... "

            $ORACLE_HOME/bin/sqlplus -S /nolog > ${db}/schemas/${SCHEMA}/${REPORT_OUT} <<EOFSQL
set echo off termout off heading off feedback off timing off
connect $CONN
@reports/by_schema/${R} $SCHEMA
exit
EOFSQL
            ERR=$?
            if [ $ERR -eq 0 ]; then
              echo 'ok'
            else
              echo 'failed'
            fi
            unset REPORT_OUT
          fi
          unset REPORT
        done
        unset SCHEMA
      done
    else
      echo "Environment with connection string for \"$e - $t\" is not defined in .dba.env"
    fi
    unset CONN
  fi
done

unset db
unset DBS
unset REPORTS
unset SCHEMAS
                                                                                                                                                                                                   
