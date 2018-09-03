#! /bin/sh
DISKS=${1:-"/dev/oracleasm/disks/*"}
rm /tmp/kfed_DH.out /tmp/kfed_FS.out /tmp/kfed_BK.out /tmp/kfed_FD.out /tmp/kfed_DD.out 2>/dev/null
for i in `ls $DISKS 2>/dev/null`; do
  echo $i >> /tmp/kfed_DH.out
  kfed read $i >> /tmp/kfed_DH.out
  echo $i >> /tmp/kfed_FS.out
  kfed read $i blkn=1 >> /tmp/kfed_FS.out
  echo $i >> /tmp/kfed_BK.out
  kfed read $i aun=1 blkn=254 >> /tmp/kfed_BK.out
  echo $i >> /tmp/kfed_FD.out
  kfed read $i aun=2 blkn=1 >> /tmp/kfed_FD.out
  echo $i >> /tmp/kfed_DD.out
  kfed read $i aun=2 blkn=2 >> /tmp/kfed_DD.out
done

