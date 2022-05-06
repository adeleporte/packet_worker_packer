#!/bin/bash

# Bootstrap script

#set -euo pipefail

if [ -e /root/ran_customization ]; then
    exit
else

    echo -e "\e[92mStart appliance customization ..." > /dev/console

    ROOT_PASSWORD_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.root_password")

    NETWORK_CONFIG_FILE=$(ls /etc/systemd/network | grep .network)
    HOSTNAME_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.hostname")
    IP_ADDRESS_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.ipaddress")
    NETMASK_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.netmask")
    GATEWAY_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.gateway")
    DNS_SERVER_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.dns")
    DNS_DOMAIN_PROPERTY=$(vmtoolsd --cmd "info-get guestinfo.ovfEnv" | grep "guestinfo.domain")

    IP_ADDRESS=$(echo "${IP_ADDRESS_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    HOSTNAME=$(echo "${HOSTNAME_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    NETMASK=$(echo "${NETMASK_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    GATEWAY=$(echo "${GATEWAY_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    DNS_SERVER=$(echo "${DNS_SERVER_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    DNS_DOMAIN=$(echo "${DNS_DOMAIN_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')

    echo -e "\e[92mConfiguring root password ..." > /dev/console
    ROOT_PASSWORD=$(echo "${ROOT_PASSWORD_PROPERTY}" | awk -F 'oe:value="' '{print $2}' | awk -F '"' '{print $1}')
    echo "root:${ROOT_PASSWORD}" | /usr/sbin/chpasswd


    ##################################
    ### No User Input, assume DHCP ###
    ##################################
    if [ -z "${IP_ADDRESS}" ]; then
        cat > /etc/systemd/network/${NETWORK_CONFIG_FILE} << __CUSTOMIZE_PHOTON__
[Match]
Name=e*

[Network]
DHCP=yes
IPv6AcceptRA=no
__CUSTOMIZE_PHOTON__
    #########################
    ### Static IP Address ###
    #########################
    else
        echo -e "\e[92mConfiguring Static IP Address ..." > /dev/console
        cat > /etc/systemd/network/${NETWORK_CONFIG_FILE} << __CUSTOMIZE_PHOTON__
[Match]
Name=e*

[Network]
Address=${IP_ADDRESS}/${NETMASK}
Gateway=${GATEWAY}
DNS=${DNS_SERVER}
Domain=${DNS_DOMAIN}
__CUSTOMIZE_PHOTON__

        echo "${IP_ADDRESS} ${HOSTNAME}" >> /etc/hosts
        echo -e "\e[92mRestarting Network ..." > /dev/console
        systemctl restart systemd-networkd
    fi

    echo -e "\e[92mConfiguring hostname ..." > /dev/console
    hostnamectl set-hostname ${HOSTNAME}

    echo -e "> Start atp_replay"
    systemctl enable worker
    systemctl start worker
    # cd /opt/arcade && curl https://raw.githubusercontent.com/adeleporte/arcade2/main/docker-compose.yml -o docker-compose.yml && docker-compose up -d
fi