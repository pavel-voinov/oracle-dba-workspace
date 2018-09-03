#!/bin/bash
#
#
TOOLS_DIR=`dirname $0`

if [ $# -lt 3 ] ; then
  echo "Usage: $0 <username> <filter to get hosts> <script file> [<script arguments>]"
  exit 2
fi

USER=${1:-'root'}
h=$2
SCRIPT=$3
ARGS=${*:4}
S=`basename $SCRIPT`

if [[ -n "$SCRIPT" && -f "$SCRIPT" ]]; then
  echo "Script to copy and execute: ${SCRIPT}"
  echo
  echo "== $h =="

  if [ "$USER" = 'root' ]; then
    $TOOLS_DIR/scp.exp root notwest $h /tmp/ $SCRIPT
    $TOOLS_DIR/sshlogin.exp root notwest $h sh /tmp/$S $ARGS
    $TOOLS_DIR/sshlogin.exp root notwest $h rm /tmp/$S
  else
    scp -o StrictHostKeyChecking=no -q -r $SCRIPT $USER@$h:/tmp/
    ssh -o StrictHostKeyChecking=no -q $USER@$h /tmp/$S $ARGS
    ssh -o StrictHostKeyChecking=no -q $USER@$h rm /tmp/$S
  fi
  echo
else
  echo "Script to copy and run is not found"
  exit 2
fi
