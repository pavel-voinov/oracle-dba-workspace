#!/bin/bash
WALLET=${1:-'default'}
FILTER=${2:-".*"}

[ -f ~/.workspace ] && . ~/.workspace

if [[ ! -x $ORACLE_HOME/bin/mkstore ]]; then
  exit 0
fi

if [ "$WALLET" == 'default' ]; then
  WALLET_DIR=$TEAM_WALLET_DIR
else
  WALLET_DIR=$PRODUCT_WALLETS_DIR/$WALLET
fi

if [ ! -d $WALLET_DIR ]; then
  echo "Wallet directory \"$WALLET_DIR\" is not found"
  exit 2
fi

$ORACLE_HOME/bin/mkstore -wrl $WALLET_DIR -listCredential < $HOME/.wallet_pwd | grep -E "^[0-9]*: .*$FILTER.*" |  awk '{print($2)}' | sort
