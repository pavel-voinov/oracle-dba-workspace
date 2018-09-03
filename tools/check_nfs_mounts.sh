#!/bin/bash
#
#
for d in shared storage; do
  D="/$d"
  if [ ! -d /shared ]; then
    echo "Directory $D doesn't exist"
    mkdir $D
    echo "Directory $D created"
  fi
  mount | grep -q "$D " >/dev/null
  if [ $? -ne 0 ]; then
    echo -n "$D is not mounted"

    egrep -q "^[^#].* $D " /etc/fstab >/dev/null
    if [ $? -ne 0 ]; then
      echo -n " and doesn't"
    else
      echo -n " and doesn't"
      f2=0
    fi
    echo "exist in /etc/fstab"
  fi
done

# temporary solution
# as root:
# if /shared is not mounted
#mkdir /shared && chown oracle:oinstall /shared
# if /storage is mounted
#mkdir /storage/oracle && chown oracle:oinstall /storage/oracle
#su - oracle -c "[ ! -L /shared/oracle ] && ln -s /storage/oracle /shared/oracle"
