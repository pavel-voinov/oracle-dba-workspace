#!/bin/bash

SCHEMA=${1:-'*'}
SCHEMA_=${1:-'ALL'}
DB1=${2:-"NG.QAEDC"}
DB2=${3:-"NG.PRODEDC"}
REPORT=${4:-"/tmp/$DB1-$DB2-${SCHEMA_}_`date +%Y%m%d`.diff"}

echo "Databases to compare:"
echo "  left side: $DB1"
echo " right side: $DB2"
echo "Schema(s) to compare: ${SCHEMA_}"
echo "Output report: $REPORT"

for r in `find -maxdepth 1 -type d -exec basename "{}" \; | grep -v '^.$' 2>/dev/null`; do
  R=`basename $r`
  RL="${DB1}/schemas/$SCHEMA/${R}"
  RR="${DB2}/schemas/$SCHEMA/${R}"

  echo "Report to compare: $R"
  if [ -e "$RR" ]; then
    diff -u $RL $RR
  else
    echo "Report $R on right site is not found"
  fi
done

unset r R RL RR DB1 DB2 REPORT
