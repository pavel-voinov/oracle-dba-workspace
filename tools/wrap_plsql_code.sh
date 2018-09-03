#!/bin/sh
#
#

for f in `ls src/*.pks src/*.pkb src/*.sql 2>/dev/null` ; do
  F=`basename $f`
  $ORACLE_HOME/bin/wrap iname=$f oname=${F}
done
