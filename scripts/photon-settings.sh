#!/bin/bash -eux

##
## Misc configuration
##

echo '> Disable IPv6'
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf

echo '> Applying latest Updates...'
tdnf -y update

echo '> Installing Additional Packages...'
tdnf install -y \
  less \
  logrotate \
  wget \
  unzip \
  tar \
  python3-pip \
  build-essential \
  python3-setuptools \
  python3-tools \
  python3-devel \
  python3-pip \
  jq \
  git \
  cronie \
  libpcap-devel

echo '> Create atp_replay homedir'
mkdir -p /opt/atp_replay

echo '> Enable docker'
systemctl enable docker
systemctl start docker

# echo '> Install docker-compose'
# curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# chmod +x /usr/local/bin/docker-compose
# docker-compose --version

echo '> Pull worker'
cd /root && wget https://github.com/kesly/atp_worker/blob/main/worker_linux\?raw\=true -O worker_linux
chmod +x /root/worker_linux 
# cd /opt/atp_replay && curl https://raw.githubusercontent.com/adeleporte/arcade2/main/docker-compose.yml -o docker-compose.yml && docker-compose up -d

echo '> Disable cloud-init ...'
systemctl disable cloud-init
touch /etc/cloud/cloud-init.disabled

# echo '> Create auto-update cron task'
# echo "59 23 * * * (cd /opt/arcade && curl https://raw.githubusercontent.com/adeleporte/arcade2/main/docker-compose.yml -o docker-compose.yml && /usr/local/bin/docker-compose pull && /usr/local/bin/docker-compose up -d --remove-orphans && /usr/bin/docker image prune -f) > /var/log/docker-updater.log 2>&1" > arcadecron
# crontab arcadecron
# rm arcadecron

echo '> Remove network config file'
rm -rf /etc/systemd/network/99-dhcp-en.network

echo '> Done'
