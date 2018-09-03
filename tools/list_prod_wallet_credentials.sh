#!/bin/bash
WALLET=${1}
FILTER=${2:-".*"}

[ -f ~/.workspace ] && . ~/.workspace

WALLET_DIR=$PRODUCT_WALLETS_DIR/$WALLET

if [ -d $WALLET_DIR ]; then
  $ORACLE_HOME/bin/mkstore -wrl $WALLET_DIR -listCredential < $HOME/.prod_wallet_pwd | grep -E "^[0-9]*: .*$FILTER.*" | awk '{print($2)}' | sort
else
  echo "Wallet directory $WALLET_DIR is not found"
  exit 2
fi
