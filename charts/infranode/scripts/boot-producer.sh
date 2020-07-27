#/bin/bash

set -e

PRODUCER_PRIVKEY=${PRODUCER_PRIVKEY:-}

wallet_host=127.0.0.1:8899
wdurl=http://${wallet_host}

wcmd="cleos --wallet-url ${wdurl} wallet"

function init_config {
  export config_dir=/usr/local/etc/eosio
  config_ini=${config_dir}/config.ini
  [ -d "/eosio-data" ] && ln -s /eosio-data/config.ini $config_ini # If /eosio-data exists, create a symlink for config.ini that points to /eosio-data/config.ini for persistence.
  cat $config_dir/producer.ini > $config_ini && echo >> $config_ini # Create config.ini from producer.ini and add a new line at the end of config file.
  setup_wallet $PRODUCER_PRIVKEY
  pkill keosd || :
}

function setup_backup {
  if [[ -f "/blockBackup.tar"]]; then
    cd eosio-data
    mkdir block_backup
    mv * block_backup
    mv block_backup/config.ini .
    mv /blockBackup.tar .

    tar -xf ./blockBackup.tar -C .

    rm blockBackup.tar
  fi

}

function wait_wallet_ready() {
  for (( i=0 ; i<10; i++ )); do
    ! $wcmd list 2>/tmp/wallet.txt || [ -s /tmp/wallets.txt ] || break
    sleep 3
  done
}

function import_private_key {
  local privkey=$1
  $wcmd import -n ignition --private-key $privkey | sed 's/[^:]*: //'
}

function setup_wallet {
  rm -rf ${HOME}/eosio-wallet
  keosd --http-server-address ${wallet_host} &
  wait_wallet_ready
  $wcmd create --to-console -n ignition
  local prikey=$1
  pubkey=$(import_private_key $prikey)
  echo "signature-provider = ${pubkey}=KEY:${prikey}" >> $config_ini
}

function _term() { 
  trap - SIGTERM && kill -- 0
  sleep 3
  exit 0
}

function start_nodeos {
  nodeos $* --genesis-json $config_dir/genesis.json --config-dir $config_dir --data-dir /eosio-data
}

init_config

if [[ -r /eosio-data/upgrade.sh ]]; then
  echo "Found upgrade script. Running upgrade script..."
  source /eosio-data/upgrade.sh
  echo "Upgrade script complete. Removing upgrade script."
  rm -rf /eosio-data/upgrade.sh
fi

trap _term SIGTERM

if [ "$ENABLE_BACKUP_RECOVERY" == "true" ]; then
  setup_backup
  start_nodeos $* &
  child=$!
  ! wait "$child" || exit 0
fi

start_nodeos $* &
child=$!
! wait "$child" || exit 0

start_nodeos $* --replay-blockchain &
child=$!
! wait "$child" || exit 0

start_nodeos $* --hard-replay-blockchain &
child=$!
wait "$child"