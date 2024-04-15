#!/usr/bin/env bash

# Copyright (c) 2024 eduardstula
# Author: Eduard Stula
# License: MIT
# https://github.com/eduardstula/linux-healt-checklist

RD=$(echo "\033[01;31m")
YW=$(echo "\033[33m")
GN=$(echo "\033[1;92m")
CL=$(echo "\033[m")
BFR="\\r\\033[K"
HOLD="-"
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"
ERRORS=0


set -euo pipefail
shopt -s inherit_errexit nullglob

header() {
  echo -e "    __  ___________    __  ______   ________  __________    _______________
   / / / / ____/   |  / / /_  __/  / ____/ / / / ____/ /   /  _/ ___/_  __/
  / /_/ / __/ / /| | / /   / /    / /   / /_/ / __/ / /    / / \__ \ / /   
 / __  / /___/ ___ |/ /___/ /    / /___/ __  / /___/ /____/ / ___/ // /    
/_/ /_/_____/_/  |_/_____/_/     \____/_/ /_/_____/_____/___//____//_/     
                                                                           "
}

section_header() {
  local msg="$1"
  echo -e "\n${YW}${msg}${CL}"
}

msg_info() {
  local msg="$1"
  echo -ne " ${HOLD} ${YW}${msg}..."
}

msg_ok() {
  local msg="$1"
  echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}

msg_error() {
  local msg="$1"
  ERRORS=$((ERRORS + 1))
  echo -e "${BFR} ${CROSS} ${RD}${msg}${CL}"
}

start_routines() {

    header

    section_header "System informations"

    #check if the script is running as root / sudo
    if [ "$EUID" -ne 0 ]; then
        msg_error "Please run as root"
        exit 1
    fi

    #show os version
    msg_info "Checking OS version"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        msg_ok "OS: $PRETTY_NAME"
    else
        msg_error "OS version not found"
    fi

    #show timezone
    msg_info "Checking timezone"
    TIMEZONE=$(timedatectl | awk '/Time zone/{print $3}' || true)
    msg_ok "Timezone: $TIMEZONE"

    #show CPU platform
    msg_info "Checking CPU platform"
    CPU_PLATFORM=$(uname -m)
    msg_ok "CPU: $CPU_PLATFORM"

    #show CPU cores
    msg_info "Checking CPU cores"
    CPU_CORES=$(nproc)
    msg_ok "Cores: $CPU_CORES"

    #show total memory
    msg_info "Checking total memory"
    TOTAL_MEMORY=$(free -m | awk '/^Mem:/{print $2}')
    msg_ok "Total memory: $TOTAL_MEMORY MB"

    #show free memory
    msg_info "Checking free memory"
    FREE_MEMORY=$(free -m | awk '/^Mem:/{print $4}')
    msg_ok "Free memory:  $FREE_MEMORY MB"

    #show total disk space
    msg_info "Checking total disk space"
    TOTAL_DISK=$(df -h --total / | awk '/total/{print $2}')
    msg_ok "Total disk size: $TOTAL_DISK"

    #show free disk space
    msg_info "Checking free disk space"
    FREE_DISK=$(df -h --total / | awk '/total/{print $4}')
    msg_ok "Free disk size:  $FREE_DISK"

    
    section_header "Network informations"

    #show ip address
    msg_info "Checking IP address"
    IP_ADDRESS=$(hostname -I)
    msg_ok "IP address: $IP_ADDRESS"

    #check internet connection
    msg_info "Checking internet connection"
    if ping -q -c 1 -W 1 google.com > /dev/null; then
        msg_ok "Internet connection: OK"
    else
        msg_error "Internet connection: FAIL"
    fi

    #show DNS servers
    msg_info "Checking DNS servers"
    DNS_SERVERS=$(cat /etc/resolv.conf | awk '/nameserver/{print $2}')
    msg_ok "DNS servers: $DNS_SERVERS"

    section_header "Package management"

    #show if the system is up to date
    read -p "Do you want check system updates ? (y/n): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        msg_info "Checking system updates"
        apt update
        UPDATES=$(apt list --upgradable 2>/dev/null | wc -l)
        if [ "$UPDATES" -gt 1 ]; then
            msg_error "System updates available"
            #offer to update the system
            read -p "Do you want to update the system? (y/n): " -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                apt upgrade -y
            fi
        else
            msg_ok "System up to date"
        fi
    fi

    section_header "Security"

    #if distro is ubuntu, check if "pro" is installed
    msg_info "Checking Ubuntu Pro"
    if [ "$ID" == "ubuntu" ]; then
        if [ -f /usr/bin/pro ]; then
            msg_ok "Pro installed"
        else
            msg_error "Pro not installed"
            #offer to install Ubuntu Pro
            read -p "Do you want to install Ubuntu Pro? (y/n): " -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                apt install -y ubuntu-advantage-tools
            fi
        fi
    fi

    #check if Unattended Upgrades is enabled
    msg_info "Checking Unattended Upgrades"
    if [ -f /etc/apt/apt.conf.d/20auto-upgrades ]; then
        msg_ok "Unattended Upgrades enabled"
    else
        msg_error "Unattended Upgrades not enabled"
        #offer to enable Unattended Upgrades
        read -p "Do you want to enable Unattended Upgrades? (y/n): " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            apt install -y unattended-upgrades
            dpkg-reconfigure -plow unattended-upgrades
        fi
    fi

    #check if UFW is installed and enabled and show status
    msg_info "Checking UFW"
    if [ -f /etc/ufw/ufw.conf ]; then
        UFW_STATUS=$(ufw status | awk '/Status:/{print $2}' || true)
        if [ "$UFW_STATUS" == "active" ]; then
            msg_ok "UFW enabled"
        else
            msg_error "UFW not enabled"
            #offer to enable UFW
            read -p "Do you want to enable UFW? (y/n): " -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                ufw enable
            fi
        fi
    else
        msg_error "UFW not installed"
        #offer to install UFW
        read -p "Do you want to install UFW? (y/n): " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            apt install -y ufw
        fi
    fi

    #check if fail2ban is installed and enabled and show status
    msg_info "Checking Fail2Ban"
    if [ -f /etc/fail2ban/fail2ban.conf ]; then
        FAIL2BAN_STATUS=$(systemctl is-enabled fail2ban)
        if [ "$FAIL2BAN_STATUS" == "enabled" ]; then
            msg_ok "Fail2Ban enabled"
        else
            msg_error "Fail2Ban not enabled"
            #offer to enable Fail2Ban
            read -p "Do you want to enable Fail2Ban? (y/n): " -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                systemctl enable fail2ban
                systemctl start fail2ban
            fi
        fi
    else
        msg_error "Fail2Ban not installed"
        #offer to install Fail2Ban
        read -p "Do you want to install Fail2Ban? (y/n): " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            apt install -y fail2ban
        fi
    fi

    #show SSH port
    msg_info "Checking SSH port"
    SSH_PORT=$(ss -tlnp | grep sshd | awk '{print $4}' | cut -d: -f2) || true
    msg_ok "SSH Port: $SSH_PORT"

    #show if root login is disabled in sshd_config and line is uncommented
    msg_info "Checking root login"
    ROOT_LOGIN=$(grep PermitRootLogin /etc/ssh/sshd_config | grep -v "#" | awk '{print $2}') || true
    if [ "$ROOT_LOGIN" == "no" ]; then
        msg_ok "Root login disabled"
    else
        msg_error "Root login enabled"
        #offer to disable root login
        read -p "Do you want to disable root login? (y/n): " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
            systemctl restart sshd
        fi
    fi

    #show if password authentication is disabled in sshd_config and line is uncommented
    msg_info "Checking password authentication"
    PASSWORD_AUTH=$(grep PasswordAuthentication /etc/ssh/sshd_config | grep -v "#" | awk '{print $2}') || true
    if [ "$PASSWORD_AUTH" == "no" ]; then
        msg_ok "Password authentication disabled"
    else
        msg_error "Password authentication enabled"
        #offer to disable password authentication
        read -p "Do you want to disable password authentication? (y/n): " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
            systemctl restart sshd
        fi
    fi

    #show if PermitEmptyPasswords is disabled in sshd_config and line is uncommented
    msg_info "Checking empty passwords"
    EMPTY_PASSWORDS=$(grep PermitEmptyPasswords /etc/ssh/sshd_config | grep -v "#" | awk '{print $2}') || true
    
    if [ -z "$EMPTY_PASSWORDS" ]; then
        msg_error "Empty passwords enabled"
    else
        if [ "$EMPTY_PASSWORDS" == "no" ]; then
            msg_ok "Empty passwords disabled"
        else
            msg_error "Empty passwords enabled"
            #offer to disable empty passwords
            read -p "Do you want to disable empty passwords? (y/n): " -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                #disable empty passwords and uncomment line if needed
                sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
                systemctl restart sshd
            fi
        fi
    fi

    #was used ssh-copy-id to copy the public key to the server?
    msg_info "Checking SSH key"
    SSH_KEY=$(ls -la ~/.ssh/authorized_keys | awk '{print $3}') || true
    if [ "$SSH_KEY" == "root" ]; then
        msg_ok "SSH key copied"
    else
        msg_error "SSH key not copied"
    fi


    #check SSH NOPASSWD is enabled  in sshd_config and line is uncommented
    msg_info "Checking SSH NOPASSWD"
    SSH_NOPASSWD=$(grep PermitEmptyPasswords /etc/ssh/sshd_config | grep -v "#" | awk '{print $2}') || true
    if [ "$SSH_NOPASSWD" == "no" ]; then
        msg_ok "SSH NOPASSWD disabled"
    else
        msg_error "SSH NOPASSWD enabled"
        #offer to disable SSH NOPASSWD
        read -p "Do you want to disable SSH NOPASSWD? (y/n): " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            #disable SSH NOPASSWD and uncomment line if needed
            sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
            systemctl restart sshd
        fi
    fi
    
    section_header "Monitoring"    

    #check if Zabbix Agent is installed and enabled and show status
    msg_info "Checking Zabbix Agent"
    if [ -f /etc/zabbix/zabbix_agentd.conf ]; then
        ZABBIX_AGENT_STATUS=$(systemctl is-enabled zabbix-agent)
        if [ "$ZABBIX_AGENT_STATUS" == "enabled" ]; then
            msg_ok "Zabbix Agent enabled"
        else
            msg_error "Zabbix Agent not enabled"
            #offer to enable Zabbix Agent
            read -p "Do you want to enable Zabbix Agent? (y/n): " -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                systemctl enable zabbix-agent
                systemctl start zabbix-agent
            fi
        fi
    else
        msg_error "Zabbix Agent not installed"
    fi

}

start_routines