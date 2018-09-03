#!/bin/bash
#
#
CONN=$1
SCRIPT=$2

if [ $# -lt 1 ] ; then
  echo "Usage: $0 <db connection>"
  exit 99
fi

tmpfile=`mktemp`
if [ -n "$SCRIPT" ]; then
  echo "@$SCRIPT" >> $tmpfile
fi
for f in `ls *.sql *.pks *.pkb *.pls 2>/dev/null`; do
  echo "@$f" >> $tmpfile
done

[ -f ~/oracle-dba/tools/dba_functions ] && . ~/oracle-dba/tools/dba_functions

if [ -s $tempfile ]; then
#  check_db_connection '-' $CONN
#  retval=$?
  retval=0
  if [ $retval -eq 0 ]; then
    $ORACLE_HOME/bin/sqlplus -L -S $CONN <<EOFSQL
set serveroutput on size 100000 echo on scan off sqlblanklines on
spool $tmpfile.log
@$tmpfile
spool off
exit
EOFSQL
    rm $tmpfile
  else
    echo "Connection to \"$CONN\" was not successful with message:"
    echo "$OUTPUT"
  fi
else
  echo "*.sql, *.pks, *.pkb and *.pls scripts don't exist in current directory"
  exit 2
fi

unset OUTPUT CONN retval
