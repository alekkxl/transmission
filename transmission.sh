#!/bin/bash

while [[ $# -ge 1 ]]; do
  case $1 in
    -p|--password)
      shift
      TRANSPASStmp="$1"
      shift
      ;;
    -u|--user)
      shift
      TRANSUSRtmp="$1"
      shift
      ;;
    --port)
      shift
      TRANSPORTtmp="$1"
      shift
      ;;
    *)
      echo -ne " Usage:\n\t -p/--password RPC password default(xiaofd.win) \n\t -u/--user RPC username default(xiaofd) \n\t --port RPC port default(9091) recommend not modified"
      exit 1;
      ;;
    esac
  done

TRANSPORT=$TRANSPORTtmp
TRANSUSR=$TRANSUSRtmp
TRANSPASS=$TRANSPASStmp

[ -z "$TRANSPORTtmp" ] && TRANSPORT=9091
[ -z "$TRANSUSRtmp" ] && TRANSUSR='admin'
[ -z "$TRANSPASStmp" ] && TRANSPASS='alek'
yum install epel-release
yum -y update
yum install transmission-cli transmission-common transmission-daemon
systemctl stop transmission-daemon.service

cp /var/lib/transmission/.config/transmission-daemon/settings.json ~
cd /var/lib/transmission/.config/transmission-daemon/
cp settings.json settings.json.old

sed 's/"rpc-authentication-required".*/"rpc-authentication-required": true,/g' -i settings.json
sed 's/"rpc-bind-address".*/"rpc-bind-address": "0.0.0.0",/g' -i settings.json
sed 's/"rpc-enabled".*/"rpc-enabled": true,/g' -i settings.json
sed "s/\"rpc-password\".*/\"rpc-password\": \"$TRANSPASS\",/g" -i settings.json
sed "s/\"rpc-port\".*/\"rpc-port\": $TRANSPORT,/g" -i settings.json
sed 's#"rpc-url".*#"rpc-url": "/transmission/",#g' -i settings.json
sed "s/\"rpc-username\".*/\"rpc-username\": \"$TRANSUSR\", /g" -i settings.json
sed 's/"rpc-whitelist".*/"rpc-whitelist": "*",/g' -i settings.json
sed 's/"rpc-whitelist-enabled".*/"rpc-whitelist-enabled": true,/g' -i settings.json
sed 's/"download-queue-size".*/"download-queue-size": 999,/g' -i settings.json
sed 's/"max-peers-global".*/"max-peers-global": 99999,/g' -i settings.json
sed 's/"umask".*/"umask": 0,/g' -i settings.json
sed 's/"pex-enabled".*/"pex-enabled": false,/g' -i settings.json
sed 's/"dht-enabled".*/"dht-enabled": false,/g' -i settings.json
sed '2a "watch-dir":"/root/torrents",' -i settings.json
sed '2a "watch-dir-enabled":true,' -i settings.json

systemctl start transmission-daemon.service

sed '2 i systemctl start transmission-daemon.service' -i /etc/rc.local

