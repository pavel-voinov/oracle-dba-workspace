#!/bin/bash
TNSALIAS=$1
DB_USER=${2:-'system'}
DB_PASSWORD=${3:-"$SYSTEM_PWD"}
WALLET=${4:-'default'}

[ -f ~/.workspace ] && . ~/.workspace

if [ "$WALLET" == 'default' ]; then
  WALLET_DIR=$TEAM_WALLET_DIR/common
  HOST_WALLET_DIR=$TEAM_WALLET_DIR/`hostname -s`
else
  WALLET_DIR=$PRODUCT_WALLETS_DIR/$WALLET
fi

if [ ! -d $WALLET_DIR ]; then
  echo "Wallet directory $WALLET_DIR is not found"
  exit 2
fi

if [ ! -f "$WALLET_DIR/ewallet.p12" ]; then
  mkdir -p $WALLET_DIR
  cat $HOME/.wallet_pwd $HOME/.wallet_pwd | $ORACLE_HOME/bin/mkstore -wrl $WALLET_DIR -create
fi
if [[ -n "$HOST_WALLET_DIR" && ! -f "$HOST_WALLET_DIR/ewallet.p12" ]]; then
  mkdir -p $HOST_WALLET_DIR
  cat $HOME/.wallet_pwd $HOME/.wallet_pwd | $ORACLE_HOME/bin/orapki wallet create -wallet $HOST_WALLET_DIR -auto_login_local
fi

if [ -z "$TNSALIAS" ]; then
  echo "TNS Alias must be specified"
  exit 2
fi

if [ -f "$WALLET_DIR/ewallet.p12" ]; then
  $ORACLE_HOME/bin/mkstore -wrl $WALLET_DIR -createCredential "$TNSALIAS" "$DB_USER" "$DB_PASSWORD" < $HOME/.wallet_pwd
else
  echo "Wallet [$WALLET_DIR] does not exist"
  exit 2
fi

if [ -n "$HOST_WALLET_DIR" ]; then
  if [ -f "$HOST_WALLET_DIR/ewallet.p12" ]; then
    $ORACLE_HOME/bin/mkstore -wrl $HOST_WALLET_DIR -createCredential "$TNSALIAS" "$DB_USER" "$DB_PASSWORD" < $HOME/.wallet_pwd
  else
    echo "Wallet [$HOST_WALLET_DIR] does not exist"
    exit 2
  fi
fi

