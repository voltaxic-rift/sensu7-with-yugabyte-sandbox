#!/bin/bash

set -eux

export $(cat /vagrant/.env | grep -v ^#)

dnf install -y /vagrant/vendor/minio-${MINIO_VERSION}.x86_64.rpm

group_entry="$(getent group minio-user)" || true
if [ -z "${group_entry}" ]; then
  groupadd -r minio-user
fi

user_entry="$(getent passwd minio-user)" || true
if [ -z "${user_entry}" ]; then
    useradd -M -r -g minio-user minio-user
fi

mkfs.xfs /dev/vdb -L DISK1
echo "LABEL=DISK1 /mnt/disk1 xfs defaults,noatime 0 2" >> /etc/fstab
mkdir /mnt/disk1
mount -a
chown minio-user:minio-user /mnt/disk1

cat << EOS > /etc/default/minio
MINIO_VOLUMES="http://192.168.57.20{1...3}:19000/mnt/disk1/minio"
MINIO_OPTS="--address :19000 --console-address :19001"
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin
EOS

systemctl enable --now minio.service
