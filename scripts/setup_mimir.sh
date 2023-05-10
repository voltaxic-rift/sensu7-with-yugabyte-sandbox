#!/bin/bash

set -eux

export $(cat /vagrant/.env | grep -v ^#)
LOCAL_ADDR=`ip a | grep -P '192.168.5[67]' | awk '{print $2}' | awk -F/ '{print $1}'`

dnf install -y epel-release
dnf install -y awscli

if ! aws --endpoint-url http://localhost:19000 s3 ls s3://mimir-blocks; then
    aws --endpoint-url http://localhost:19000 s3 mb s3://mimir-blocks
fi
if ! aws --endpoint-url http://localhost:19000 s3 ls s3://mimir-ruler; then
    aws --endpoint-url http://localhost:19000 s3 mb s3://mimir-ruler
fi
if ! aws --endpoint-url http://localhost:19000 s3 ls s3://mimir-alertmanager; then
    aws --endpoint-url http://localhost:19000 s3 mb s3://mimir-alertmanager
fi

dnf install -y /vagrant/vendor/mimir-${MIMIR_VERSION}_amd64.rpm

mkdir -p /var/log/mimir
mkdir -p /var/lib/mimir
chown mimir:mimir /var/log/mimir
chown mimir:mimir /var/lib/mimir

cat << EOS > /etc/sysconfig/mimir
LOG_LEVEL="info"
CUSTOM_ARGS="-config.file /etc/mimir/config.yaml"
RESTART_ON_UPGRADE="true"
EOS

cat << EOS > /etc/mimir/config.yaml
target: all,alertmanager

multitenancy_enabled: true

server:
  http_listen_port: 9009

distributor:
  ring:
    instance_addr: "${LOCAL_ADDR}"

ingester:
  ring:
    instance_addr: "${LOCAL_ADDR}"

frontend:
  address: "${LOCAL_ADDR}"

blocks_storage:
  backend: s3
  s3: &s3
    endpoint: localhost:19000
    bucket_name: mimir-blocks
    secret_access_key: minioadmin
    access_key_id: minioadmin
    insecure: true
  bucket_store:
    sync_dir: /var/lib/mimir/tsdb-sync/
  tsdb:
    dir: /var/lib/mimir/tsdb/

compactor:
  sharding_ring:
    instance_addr: "${LOCAL_ADDR}"
  data_dir: /var/lib/mimir/data-compactor/

store_gateway:
  sharding_ring:
    instance_addr: "${LOCAL_ADDR}"

activity_tracker:
  filepath: /var/log/mimir/metrics-activity.log

ruler:
  ring:
    instance_addr: "${LOCAL_ADDR}"
  rule_path: /var/lib/mimir/data-ruler/
  alertmanager_url: http://localhost:9009/alertmanager

ruler_storage:
  backend: s3
  s3:
    <<: *s3
    bucket_name: mimir-ruler

alertmanager:
  sharding_ring:
    instance_addr: "${LOCAL_ADDR}"
  data_dir: /var/lib/mimir/data-alertmanager/
  external_url: http://localhost:9009/alertmanager
  fallback_config_file: /etc/mimir/alertmanager-fallback-config.yml

alertmanager_storage:
  backend: s3
  s3:
    <<: *s3
    bucket_name: mimir-alertmanager

memberlist:
  advertise_addr: "${LOCAL_ADDR}"
  join_members:
  - "192.168.57.201"
  - "192.168.57.202"
  - "192.168.57.203"

limits:
  ruler_max_rules_per_rule_group: 0
  ruler_max_rule_groups_per_tenant: 0
EOS

cat << EOS > /etc/mimir/alertmanager-fallback-config.yml
route:
  group_wait: 0s
  receiver: empty-receiver

receivers:
  # In this example we're not going to send any notification out of Alertmanager.
  - name: 'empty-receiver'
EOS

systemctl restart mimir
