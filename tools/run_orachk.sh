#!/bin/bash
#
#
# Shell script to execute orachk utility
#
if [ -z "`id -u oracle 2>/dev/null`" ]; then
  echo "You must be logged in as oracle user"
  exit 1
fi

if [ -f $HOME/.bash_profile ]; then
  . $HOME/.bash_profile
fi

BIN_DIR=$ORACLE_BASE/orachk
REPORTS_DIR=/shared/oracle/tools/orachk/reports

if [ ! -e "$BIN_DIR/orachk" ]; then
  echo "\"orachk\" executable isn't found in \"$BIN_DIR\""
  exit 2
fi

sudo -l 2>/dev/null | grep -q 'root_orachk.sh' >/dev/null
if [ $? -ne 0 ]; then
  echo "sudo for \"root_orachk.sh\" isn't configured"
  exit 1
fi

if [ ! -d "$REPORTS_DIR" ]; then
  mkdir -p "$REPORTS_DIR"
  if [ $? -ne 0 ]; then
    echo "Directory \"$REPORTS_DIR\" doesn't exist and cannot be created'"
    exit 2
  fi
fi

"$BIN_DIR/orachk" -a -dball -output "$REPORTS_DIR" -s
