#!/bin/bash
function send_mail() {
  subject=$1
  msg=$2
  to=${3:-'ghost-dba@yandex.ru'}

  tmpfile=`mktemp`
  echo "$msg" > $tmpfile
  mail -s "$subject" $to < $tmpfile
  rm $tmpfile
}

send_mail "$1" "$2" "$3"
