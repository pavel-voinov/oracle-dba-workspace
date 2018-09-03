#!/bin/bash
TNSALIAS=$1
WALLET=${2}

[ -f ~/.workspace ] && . ~/.workspace

WALLET_DIR=$PRODUCT_WALLETS_DIR/$WALLET

if [ ! -d $WALLET_DIR ]; then
  echo "Wallet directory $WALLET_DIR is not found"
  exit 2
fi

if [ -z "$TNSALIAS" ]; then
  echo "TNS Alias must be specified"
  exit 2
fi

if [ -f "$WALLET_DIR/ewallet.p12" ]; then
  $ORACLE_HOME/bin/mkstore -wrl $WALLET_DIR -deleteCredential "$TNSALIAS" < $HOME/.prod_wallet_pwd
else
  echo "Wallet [$WALLET_DIR] does not exist"
  exit 2
fi
