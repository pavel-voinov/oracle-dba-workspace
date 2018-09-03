#!/bin/bash

cmdfile=$1

if [ ! -f $cmdfile ]; then
  echo "RMAN command file $cmdfile is not found."
  exit 2
fi

. /shared/oracle/bin/set_ora_env

$ORACLE_HOME/bin/rman target / catalog /@rman-catalog cmdfile="$cmdfile"
