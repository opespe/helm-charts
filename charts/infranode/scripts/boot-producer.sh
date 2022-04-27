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
  if [[ -f "/blockBackup.tar" ]]; then
    mkdir -p backup_block_log
    cd eosio-data
    if ls block* 1> /dev/null 2>&1; then
      mv block* ../backup_block_log
    fi
    if ls lost* 1> /dev/null 2>&1; then
      mv lost* ../backup_block_log
    fi
    if ls snap* 1> /dev/null 2>&1; then
      mv snap* ../backup_block_log
    fi
    if ls state* 1> /dev/null 2>&1; then
      mv state* ../backup_block_log
    fi
    cp config.ini ../backup_block_log
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

function get_snapshot {
  echo "File URI: $SNAPSHOT_FILE_URI "
  SNAPSHOT_NAME=$(basename $SNAPSHOT_FILE_URI)
  echo "File Name: $SNAPSHOT_NAME "
  gsutil cp $SNAPSHOT_FILE_URI /tmp/$SNAPSHOT_NAME
  tar -C /tmp -zxvf /tmp/$SNAPSHOT_NAME
  rm /tmp/$SNAPSHOT_NAME
}

function start_nodeos {
  echo "000000000000000  started nodeos function 0"
  nodeos $* --genesis-json $config_dir/genesis.json --config-dir $config_dir --data-dir /eosio-data
}

echo "init_config start"
init_config
echo "init_config end"

echo "start upgrade.sh start"
if [[ -r /eosio-data/upgrade.sh ]]; then
  echo "Found upgrade script. Running upgrade script..."
  source /eosio-data/upgrade.sh
  echo "Upgrade script complete. Removing upgrade script."
  rm -rf /eosio-data/upgrade.sh
fi
echo "end of unpgrade.sh end"

echo "trap _term SIGTERM start"
trap _term SIGTERM
echo "trap _term SIGTERM end"

echo "1111111111 enablling backup recovery - debug 1"
if [ "$ENABLE_BACKUP_RECOVERY" == "true" ]; then
  echo "setting up backup recovery - debug 1a"
  setup_backup
  echo "nodes command executed - debug 1b"
  start_nodeos $* &
  child=$!
  ! wait "$child" || exit 0
fi

# echo "running backup recovery nodes command even outside if loop"
# start_nodeos $* &
# child=$!
# ! wait "$child" || exit 0

echo "2222222222 enablling snapshot recovery - debug 2"
if [ "$ENABLE_SNAPSHOT_RECOVERY" == "true" ]; then
  echo "getting snapshot - debug 2a"
  get_snapshot
  echo "start_nodeos  --delete-all-blocks --snapshot command - debug 2b"
  start_nodeos $* --delete-all-blocks --snapshot "$(ls -t /tmp/*.bin | head -n1)" &
  child=$!
  ! wait "$child" || exit 0
fi

echo "3333333333 replay-blockchain - debug 3"
start_nodeos $* --replay-blockchain &
child=$!
! wait "$child" || exit 0

echo "4444444444 hard-replay-blockchain  - debug 4"
start_nodeos $* --hard-replay-blockchain &
child=$!
wait "$child"
echo "******************* end of all commands"