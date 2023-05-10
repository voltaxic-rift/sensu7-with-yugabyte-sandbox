#!/bin/bash

set -eux

export $(cat /vagrant/.env | grep -v ^#)

dnf install -y epel-release
dnf install -y nginx

cd ~/
\cp -f /vagrant/vendor/sensu-go-webui-${SENSU_GO_WEBUI_COMMIT_HASH}.tgz ~/
tar zxvf ~/sensu-go-webui-${SENSU_GO_WEBUI_COMMIT_HASH}.tgz

cat << 'EOS' > /etc/nginx/conf.d/sensu.conf
upstream sensu {
    server 192.168.57.201:8080;
    server 192.168.57.202:8080;
    server 192.168.57.203:8080;
}

server {
    listen       3000;
    server_name  sensu-distributed-ui;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
        try_files $uri /index.html;
    }

    location ~ ^/(auth|graphql|api) {
        proxy_pass http://sensu;
        proxy_set_header Host               $host;
        proxy_set_header X-Real-IP          $remote_addr;
        proxy_set_header X-Forwarded-Host   $host;
        proxy_set_header X-Forwarded-Server $host;
        proxy_set_header X-Forwarded-For    $proxy_add_x_forwarded_for;
    }
}

server {
    listen       3030;
    server_name  sensu-local-ui;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
        try_files $uri /index.html;
    }

    location ~ ^/(auth|graphql|api) {
        proxy_pass http://localhost:8080;
        proxy_set_header Host               $host;
        proxy_set_header X-Real-IP          $remote_addr;
        proxy_set_header X-Forwarded-Host   $host;
        proxy_set_header X-Forwarded-Server $host;
        proxy_set_header X-Forwarded-For    $proxy_add_x_forwarded_for;
    }
}
EOS

\cp -rf ~/package/build/app/* /usr/share/nginx/html/


cat << 'EOS' > /etc/nginx/conf.d/mimir.conf
upstream mimir {
    server 192.168.57.201:9009 max_fails=1 fail_timeout=1s;
    server 192.168.57.202:9009 max_fails=1 fail_timeout=1s;
    server 192.168.57.203:9009 max_fails=1 fail_timeout=1s;
}

server {
    listen       9010;
    server_name  mimir;

    location / {
        proxy_pass http://mimir;
    }
}
EOS

setenforce 0
systemctl restart nginx
