#!/bin/bash

set -eux

export $(cat /vagrant/.env | grep -v ^#)
LOCAL_ADDR=`ip a | grep -P '192.168.5[67]' | awk '{print $2}' | awk -F/ '{print $1}'`

dnf install -y epel-release
dnf install -y python39
dnf install -y /vagrant/vendor/yugabytedb-${YB_VERSION}-${YB_RPM_REVISION}.x86_64.rpm

cat << EOS > /etc/yugabytedb/yb-master.conf
--master_addresses=192.168.57.201:7100,192.168.57.202:7100,192.168.57.203:7100
--rpc_bind_addresses=$LOCAL_ADDR:7100
--fs_data_dirs=/var/lib/yugabytedb
EOS

cat << EOS > /etc/yugabytedb/yb-tserver.conf
--tserver_master_addrs=192.168.57.201:7100,192.168.57.202:7100,192.168.57.203:7100
--rpc_bind_addresses=$LOCAL_ADDR:9100
--enable_ysql
--pgsql_proxy_bind_address=0.0.0.0:5433
--cql_proxy_bind_address=0.0.0.0:9042
--fs_data_dirs=/var/lib/yugabytedb
EOS

systemctl enable --now yb-master.service
systemctl enable --now yb-tserver.service
