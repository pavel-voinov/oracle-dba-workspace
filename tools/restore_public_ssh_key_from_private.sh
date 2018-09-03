#!/bin/bash
#
# Script to restore SSH public key from private one
#
if [[ ! -f $1 ]]; then
  echo "File $1 not found"
  exit 1
fi

ssh-keygen -y -f $1
