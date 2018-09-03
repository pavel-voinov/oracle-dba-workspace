#!/bin/bash
MASK=${1:-'*_TEST*.trc'}
SORT=${2:-'fchela'}

CMD="find -iname '$MASK'"

for f in `eval $CMD`; do
  r=`basename $f`
  r="${r%.*}.out"

  echo "$f:"

  if [ -f "$r" ]; then
    echo "report file $r already exists"
  else
    tkprof $f $r sort=$SORT sys=no aggregate=yes waits=yes
    touch --reference=$f $r
  fi
done
