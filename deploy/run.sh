#!/usr/bin/env bash

# usage ./run.sh --instance_id=id

function usage(){
  echo "Usage: $0 --instance id"
  exit 1
}

instance_id=""
while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
    --instance)
      instance_id="$2"
      shift
      shift
      ;;
    *)
      usage
      ;;
  esac
done

if [ -z "$instance_id" ]; then
  usage
fi

function genconfig() {
  idx=$1
  serf_base_port=8410
  rpc_base_port=8400
  serf_port=$(($serf_base_port + $idx))
  rpc_port=$(($rpc_base_port + $idx))
  echo "rpc-port: $rpc_port"
  echo bind-addr: "localhost:$serf_port"
  echo node-name: "node-$idx"
  echo bootstrap: $([ "$idx" = "0" ] && echo "true" || echo "false")
  if [ "$idx" != "0" ]; then
    echo start-join-addrs: "localhost:$serf_base_port"
  fi
}

bin=./proglog
instance_dir="./instance-$instance_id"
config_filename="$instance_dir/config.yaml"
datadir="$instance_dir/data"
mkdir -p $instance_dir
mkdir -p $data_dir
genconfig $instance_id > $config_filename
echo instance will be started with the following config:
echo "--"
cat $config_filename
echo "--"
CONFIG_DIR=../config $bin --config-file=$config_filename --data-dir=$datadir
