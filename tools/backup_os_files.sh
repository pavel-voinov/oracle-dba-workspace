#!/bin/bash

if [ $# -lt 1 ] ; then
  echo "Usage: $0 <database name (LS_DEV, LS_PERF, LS_QA_EDC, ...)> [<base directory path. Default is /shared/oracle/backup/{DB_NAME}>]"
  exit 1
fi

H=`hostname -s`
DB=$1
BASE_DIR=${2:-"/shared/oracle/backup/${DB}"}
HOST_DIR=$BASE_DIR/OS/$H
DSTAMP=`date +%Y%m%d`

if [ ! -d $HOST_DIR ]; then
  mkdir -p $HOST_DIR && chown oracle:oinstall $HOST_DIR 
fi

if [ -f $BASE_DIR/files.lst ]; then
  FL=$BASE_DIR/files.lst
elif [ -f ./files.lst ]; then
  FL=`pwd`/files.lst
elif [ -f `dirname $0`/files.lst ]; then
  FL=`dirname $0`/files.lst
else
  echo "Files list not found"
  exit 1
fi

pushd $HOST_DIR >/dev/null

# save crontab
for u in root oracle jpharm thor chemaxon; do
  if [ `id -u $u 2>/dev/null` ]; then
    crontab -u $u -l > crontab_${u}_${DSTAMP}.txt 2>/dev/null
  fi
done
chown oracle:oinstall crontab_*_${DSTAMP}.txt

# save files
tar czv --absolute-names --dereference --ignore-failed-read --files-from=$FL -f files_${DSTAMP}.tar.gz
chown oracle:oinstall files_${DSTAMP}.tar.gz

popd >/dev/null
