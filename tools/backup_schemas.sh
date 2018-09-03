#!/bin/bash
S=${1:-"schemas.lst"}
if [ -f $S ]; then
  for s in `cat $S`; do
    expdp_schema.sh $s;
    for l in `grep -l 'successfully completed' $s_*.log`; do
      f=`echo $l | sed -e 's/\.log//g'`
      tar czv --remove-files -f $f.tar.gz ${f}.log ${f}_*.dmp &
    done
  done
fi
