#!/bin/bash
TNSALIAS=$1
DB_USER=${2}
DB_PASSWORD=${3}
WALLET=${4}

[ -f ~/.workspace ] && . ~/.workspace

WALLET_DIR=$PRODUCT_WALLETS_DIR/$WALLET

if [ ! -d $WALLET_DIR ]; then
  echo "Wallet directory $WALLET_DIR is not found"
  exit 2
fi

if [ ! -f "$WALLET_DIR/ewallet.p12" ]; then
  cat $HOME/.prod_wallet_pwd $HOME/.prod_wallet_pwd | $ORACLE_HOME/bin/mkstore -wrl $WALLET_DIR -create
fi

if [ -z "$TNSALIAS" ]; then
  echo "TNS Alias must be specified"
  exit 2
fi

if [ -f "$WALLET_DIR/ewallet.p12" ]; then
  $ORACLE_HOME/bin/mkstore -wrl $WALLET_DIR -createCredential "$TNSALIAS" "$DB_USER" "$DB_PASSWORD" < $HOME/.prod_wallet_pwd
else
  echo "Wallet [$WALLET_DIR] does not exist"
  exit 2
fi

