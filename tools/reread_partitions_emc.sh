#!/bin/bash
#
#

LIST=${1}
if [ ! -f "$LIST" ]; then
  echo "File with list of devices is not found"
  exit 1
fi

for d in `grep -v -E '^#' "$LIST"`; do
  kpartx -a -v $d
  partprobe $d
done
