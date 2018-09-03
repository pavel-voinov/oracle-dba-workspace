#!/bin/bash
#
#

LIST=${1}
if [ ! -f "$LIST" ]; then
  echo "File with list of devices is not found"
  exit 1
fi

echo "ASM disks before:"
#oracleasm scandisks
oracleasm listdisks
echo

for d in `grep -v -E '^#' "$LIST"`; do
  D=`basename $d`
  UD=`echo "$D" | tr '[:lower:]' '[:upper:]' | tail -c5` # last unique 4 chars from device name in upper case
  P=`ls ${d}*1 2>/dev/null`                  # get any name of first partition (ends with "1" usually)

  if [ -b "$P" ]; then
    oracleasm querydisk $P 2>/dev/null 1>/dev/null
    ASM=$?

    if [ $ASM -eq 1 ]; then
      ASM_NAME="EMC_$UD"
      oracleasm createdisk -v $ASM_NAME $P
    fi
  fi
done

echo
echo "ASM disks after:"
#oracleasm scandisks
oracleasm listdisks
