#!/bin/bash
FMASK=${1}

( tar -c ${FMASK}*.dmp ${FMASK}.log | gzip -c --rsyncable > ${FMASK}.tar.gz.tmp ) && rm -f ${FMASK}*.dmp ${FMASK}.log && mv ${FMASK}.tar.gz.tmp ${FMASK}.tar.gz && md5sum ${FMASK}.tar.gz > ${FMASK}.tar.gz.md5
