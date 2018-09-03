#!/bin/bash
TNSALIAS=$1
WALLET=${2:-'default'}

[ -f ~/.workspace ] && . ~/.workspace

if [ "$WALLET" == 'default' ]; then
  WALLET_DIR=$TEAM_WALLET_DIR
  HOST_WALLET_DIR=$TEAM_WALLET_DIR/`hostname -s`
else
  WALLET_DIR=$PRODUCT_WALLETS_DIR/$WALLET
fi

if [ ! -d "$WALLET_DIR" ]; then
  echo "Wallet directory \"$WALLET_DIR\" does not exist"
  exit 2
fi
if [[ -n "$HOST_WALLET_DIR" && ! -d "$HOST_WALLET_DIR" ]]; then
  echo "Wallet directory \"$HOST_WALLET_DIR\" does not exist"
  exit 2
fi

if [ -z "$TNSALIAS" ]; then
  echo "TNS Alias must be specified"
  exit 2
fi

if [ -f "$WALLET_DIR/ewallet.p12" ]; then
  $ORACLE_HOME/bin/mkstore -wrl $WALLET_DIR -deleteCredential "$TNSALIAS" < $HOME/.wallet_pwd
else
  echo "Wallet [$WALLET_DIR] does not exist"
  exit 2
fi
if [ -n "$HOST_WALLET_DIR" ]; then
  if [ -f "$HOST_WALLET_DIR/ewallet.p12" ]; then
    $ORACLE_HOME/bin/mkstore -wrl $HOST_WALLET_DIR -deleteCredential "$TNSALIAS" < $HOME/.wallet_pwd
  else
    echo "Wallet [$HOST_WALLET_DIR] does not exist"
    exit 2
  fi
fi
