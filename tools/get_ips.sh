
#SSH:
for x in cortellis staging prous; do for e in prod-edc prod-dtc staging-dtc; do for i in 1 2 3; do host $x-db-srv-$e-$i; done; for i in 1 2; do host $x-tools-srv-$e-$i; done; host $x-$e-gg; done; done | grep 'has address' | cut -d' ' -f 4 | sort -V | uniq

#SQL*Net:
for x in cortellis staging prous; do for e in prod-edc prod-dtc staging-dtc; do for i in 1 2 3; do h="$x-db-srv-$e-$i"; host $h 2>/dev/null; vip=`host $h 2>/dev/null | grep 'an alias for' | cut -d' ' -f6 | cut -d'.' -f1`; [ -n "$vip" ] && echo "$h - $vip-vip"; done; host $x-$e-db 2>/dev/null; done; done | grep 'has address' | cut -d' ' -f 4 | sort -V | uniq
