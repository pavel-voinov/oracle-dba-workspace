#!/bin/bash
#
# Script to get fingerprint from AWS-generated private key (key-pair)
#
if [[ ! -f $1 ]]; then
  echo "File $1 not found"
  exit 1
fi

openssl pkcs8 -in $1 -inform PEM -outform DER -topk8 -nocrypt | openssl sha1 -c
