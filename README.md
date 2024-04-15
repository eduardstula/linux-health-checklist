# Linux Health Checklist ✔️

Application that checks the health of a debian based linux servers.

The best way how to keep your server healthy is to check it regularly. This application will help you to check the most important configurations of your server. Keep your server up to date and secure.

**Have you HomeLab? This application is for you!**

![](assets/screenshot.png)

## 🖥️ Requirements

### Required
- Debian based linux server with apt package manager
- Root access to the server (or sudo access)
- Bash

### Optional
- Wget
- SSH access to the server

## ⚠️ Warning

When the application wants to change some configurations of the server, it will ask you for confirmation. But be careful!

You can lose access to your server if you don't know what you are doing. This application can change some configurations of your server etc. SSH port, firewall rules, etc.

## 🏃 How to use?

The simplest way to use this application is to run the following command in the terminal of the server you want to check:

```bash
bash -c "$(wget -qLO - https://raw.githubusercontent.com/eduardstula/linux-health-checklist/master/health-checklist.sh)"
```

Why use this command? This command will download the latest version of the application from the repository and run it.

### Manual installation

If you want to install the application manually, you can download the script from the repository and run it.

```bash
wget https://raw.githubusercontent.com/eduardstula/linux-health-checklist/master/health-checklist.sh
chmod +x health-checklist.sh
./health-checklist.sh
```

## 📋 Features

Table of features that the application checks:

### System informations

| Feature | Description |
| --- | --- |
| Os version | Shows the version of the operating system |
| Kernel version | Shows the version of the kernel |
| Timezone | Shows the timezone of the server |
| CPU platform | Shows the platform of the CPU |
| CPU cores | Shows the number of CPU cores |
| Total memory | Shows the total memory of the server |
| Free memory | Shows the free memory of the server |
| Total disk space | Shows the total disk space of the server |
| Free disk space | Shows the free disk space of the server |


### Network informations

| Feature | Description |
| --- | --- |
| Hostname | Shows the hostname of the server |
| Local IP | Shows the local IP address of the server |
| Internet connection | Shows if the server has an internet connection |
| DNS server | Shows the DNS server of the server |

### Package management

| Feature | Description |
| --- | --- |
| Update packages | Shows if there are any updates available |
| Security updates | Shows if there are any security updates available |

### Security

| Feature | Description |
| --- | --- |
| Ubuntu Pro | Shows if the server is using Ubuntu Pro if the server is running Ubuntu |
| Unnatended upgrades | Shows if the unattended-upgrades package is installed |
| Firewall | Shows if the UFW firewall is enabled |
| Fail2ban | Shows if the Fail2ban is installed and enabled |
| SSH port | Shows the SSH port of the server |
| SSH root login | Shows if the root login is enabled in SSH |
| SSH password authentication | Shows if the password authentication is enabled in SSH |
| Empty password | Shows if there are any users with an empty password |
| SSH keys | Shows if there are any SSH keys in the authorized_keys file |
| SSH nopasswd | Shows if there are any users with the NOPASSWD option in the sudoers file |

### Monitoring

| Feature | Description |
| --- | --- |
| Uptime | Shows the uptime of the server |
| Load average | Shows the load average of the server |
| Zabbix agent | Shows if the Zabbix agent is installed and running |

## 📖 Story

I created this application because I wanted to have a simple tool that will help me to check the health of my servers. I have a few servers in my HomeLab and I wanted to have a simple tool that will help me to check the most important configurations of the servers.

## 🫂 Contributing

If you want to contribute to this project, you can create a pull request with your changes. I will be happy to review and merge them.

## 🧪 Tested on

- Debian 12
- Raspbian 12
- Ubuntu 22.04

## 😶 Disclaimer

This application is not intended to be used in production environments. It is a simple script that shows and checks some basic configurations of a linux server.

This application ist not auditing tool. Only checks the most important configurations of the server.

Use it at your own risk. I am not responsible for any damage caused by this application.

## 📒 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.