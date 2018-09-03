#!/bin/bash
CONN=$1
TABLE=`echo "$2" | tr 'A-Z' 'a-z' | sed -r 's/\s+//g'`
SCN=$3
S3_BUCKET=$4

get_current_scn() {
  CONN=$1
  SCN=`$ORACLE_HOME/bin/sqlplus -L -S $CONN <<EOFSQL
set head off feed off echo off pagesize 0 line 150 termout on
col current_scn format 9999999999999999999
select ltrim(min(current_scn)) as current_scn from gv\\$database;
EOFSQL`
  retval=$?
  if [[ $retval -eq 0 ]]; then
    echo $SCN
  fi
  return $retval
}

if [ -n "$TABLE" ]; then
  f="${TABLE}.csv"
  if [[ -f $f ]]; then
    mv -v $f $f.bak
  fi
  tmpfile=`mktemp`
  echo "set timing off feedback off termout off heading on pagesize 9999" > $tmpfile
  echo "alter session set nls_date_format='YYYY-MM-DD HH24:MI:SS';" >> $tmpfile
  echo "alter session set nls_timestamp_format='YYYY-MM-DD HH24:MI:SS';" >> $tmpfile
  echo "alter session set nls_timestamp_tz_format='YYYY-MM-DD HH24:MI:SS TZR';" >> $tmpfile
  echo "alter session set nls_time_format='HH24:MI:SS';" >> $tmpfile
  echo "alter session set nls_time_tz_format='HH24:MI:SS TZR';" >> $tmpfile
  echo 'set sqlformat csv' >> $tmpfile
  echo "spool $f" >> $tmpfile
  if [[ -z $SCN ]]; then
    echo "SELECT * FROM $TABLE;" >> $tmpfile
  elif [[ $SCN == 'USE_CURRENT' ]]; then
    cSCN=`get_current_scn $CONN`
    retval=$?
    if [[ $retval -eq 0 ]]; then
      echo "Current SCN: $cSCN"
      echo "SELECT * FROM $TABLE AS OF SCN $cSCN;" >> $tmpfile
    else
      echo 'Error while getting current SCN'
    fi
  else
    echo "SELECT * FROM $TABLE AS OF SCN $SCN;" >> $tmpfile
  fi
  echo 'spool off' >> $tmpfile
  echo 'exit' >> $tmpfile

  if [[ $retval -eq 0 ]]; then
    time $ORACLE_BASE/product/sqlcl/bin/sql -noupdates -L $CONN @$tmpfile

    if [[ $? -eq 0 ]]; then
      rm $tmpfile
      gzip -vf $f
      if [[ -n $S3_BUCKET ]]; then
        aws s3 cp $f.gz s3://$S3_BUCKET/${TABLE%%.*}/${TABLE##*.}/${TABLE##*.}.csv.gz
      fi
    else
      echo "$tmpfile:"
      cat $tmpfile
    fi
  fi
fi
