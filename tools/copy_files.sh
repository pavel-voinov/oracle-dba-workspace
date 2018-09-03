#!/bin/bash
#
#
TOOLS_DIR=`dirname $0`
INVENTORY="$HOME/dba/setup/tss_inventory.txt"

if [ ! -f "$INVENTORY" ]; then
  echo "Inventory file $INVENTORY is not found"
  exit 1
fi

USER=${1}
FILTER=${2}
FILES=${*:3}
echo "File(s) to copy: ${FILES}"

for h in `grep -v '^#' "$INVENTORY" | grep -E "$FILTER" | awk -F':' '{print($1)}'`; do
  echo "== $h =="
  if [ "$USER" = 'root' ]; then
    $TOOLS_DIR/scp.exp root notwest $h /tmp/ ${FILES}
  else
    scp -o StrictHostKeyChecking=no -q -r ${FILES} ${USER}@${h}:/tmp/
  fi
  echo
done
