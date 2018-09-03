#!/bin/bash
for d in *; do
  if [[ "$d" = 'ggs' || "$d" = 'ggs_heartbeat' ]]; then
    zip -ur ~/work/_tmp/$d.zip $d
  elif [ "$d" = "`basename $0`" ]; then
    echo
  else
    pushd $d
    zip -ur ~/work/_tmp/$d.zip *
    popd
  fi
done
