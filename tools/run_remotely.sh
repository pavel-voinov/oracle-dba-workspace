#!/bin/bash
#
#
TOOLS_DIR=`dirname $0`
INVENTORY="$HOME/dba/setup/tss_inventory.txt"

if [ ! -f "$INVENTORY" ]; then
  echo "Inventory file $INVENTORY is not found"
  exit 1
fi

USAGE="Usage: $0 \n
  [-u/--user <user name, e.g. oracle or root. Default is \"oracle\">]\n
  [ -f/--filter <filter on hosts. All hosts if not specified> | --hostname <Single hostname> ]\n
  [--use-ecom-proxy]\n
  [-c|--command <command with arguments. Default is \"date\">]"

ARGS=`getopt -o h:u:f:c: -l help,user:,filter:,use-ecom-proxy,command:,hostname: -- "$@"`
if [ $? -ne 0 ]; then
  exit $?
fi
eval set -- "$ARGS"

# extract options and their arguments into variables.
while true ; do
    case "$1" in
        -h|--help) echo -e $USAGE; exit 0 ;;
        -u|--user)
            case "$2" in
                "") shift 2 ;;
                *) USER=$2 ; shift 2 ;;
            esac ;;
        --use-ecom-proxy)
            case "$2" in
                "") shift 2 ;;
                *) SSH_PROXY='ssh -A -t tss@pceudb28.isihost.com' ; shift ;;
            esac ;;
        -f|--filter)
            case "$2" in
                "") shift 2 ;;
                *) FILTER=$2 ; shift 2 ;;
            esac ;;
        -c|--command)
            case "$2" in
                "") shift 2 ;;
                *) CMD=$2 ; shift 2 ;;
            esac ;;
        --hostname)
            case "$2" in
                "") shift 2 ;;
                *) H=$2 ; shift 2 ;;
            esac ;;
        --) shift ; break ;;
        *) echo "Unsupported parameter"; echo -e $USAGE; exit 1 ;;
    esac
done

get_info() {
  echo `egrep "^$1" $INVENTORY 2>/dev/null | cut -d ':' -f 2,3,4,5,6 --output-delimiter='-'`
}

USER=${USER:-'oracle'}
if [ -z "$H" ]; then
  if [ -z "$FILTER" ]; then
    HOSTS=( `grep -v '^#' "$INVENTORY" | cut -d ':' -f 1` )
  else
    HOSTS=( `grep -v '^#' "$INVENTORY" | egrep "$FILTER" | cut -d ':' -f 1` )
  fi
else
  HOSTS=( $H )
fi

CMD=${CMD:-'date'}
echo "Command to execute: $CMD"

for h in "${HOSTS[@]}"; do
  echo "== $h (`get_info $h`) =="
# ping -q -c 1 -w 3 $h >/dev/null; PING=$?
  PING=0

  if [ $PING -eq 0 ]; then
    if [ "$USER" = 'root' ]; then
      if [ -z "$SSH_PROXY" ]; then
        $TOOLS_DIR/sshlogin.exp root notwest $h $CMD
      else
        $TOOLS_DIR/sshlogin_ecom.exp root notwest $h $CMD
      fi
    else
      $SSH_PROXY ssh -o NumberOfPasswordPrompts=0 -o StrictHostKeyChecking=no -q -l oracle $h "$CMD"
    fi
  else
    echo "Host $h is not reachable"
  fi
  unset PING
  echo
done

unset CMD
