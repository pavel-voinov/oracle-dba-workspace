#!/bin/bash
#
#

LIST=${1}
if [ ! -f "$LIST" ]; then
  echo "File with list of devices is not found"
  exit 1
fi

for d in `grep -v -E '^#' "$LIST"`; do
  if ( fdisk -l $d 2>&1 | grep "doesn't contain a valid partition table" >/dev/null ); then
    echo "Creating partition for $d:"
    fdisk $d << EOF
n
p
1
1

w
EOF
    kpartx -a -v $d
    partprobe $d
  fi
done
