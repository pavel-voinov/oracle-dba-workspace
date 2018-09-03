#!/bin/bash
WALLET=${1:-'default'}
FILTER=${2:-".*"}

[ -f ~/.workspace ] && . ~/.workspace

if [ "$WALLET" == 'default' ]; then
  WALLET_DIR=$TEAM_WALLET_DIR
else
  WALLET_DIR=$PRODUCT_WALLETS_DIR/$WALLET
fi

if [ -d $WALLET_DIR ]; then
  $ORACLE_HOME/bin/mkstore -wrl $WALLET_DIR -listCredential < $HOME/.wallet_pwd | grep -E "^[0-9]+: .*$FILTER.*" | sort -n | while read r; do
    i=`echo $r | awk -F':' '{print($1)}'`
    echo -n "$r "
    p=`$ORACLE_HOME/bin/mkstore -wrl $WALLET_DIR -viewEntry oracle.security.client.password$i < $HOME/.wallet_pwd 2>/dev/null | grep "oracle.security.client.password" | awk '{print($3)}'`
    echo $p
  done
else
  echo "Wallet directory $WALLET_DIR is not found"
  exit 2
fi
