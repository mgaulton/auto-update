#!/usr/bin/env bash

if [[ "$EUID" -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

if [[ -z $(command -v systemctl) ]]; then
    echo "systemctl not found"
    exit 1
fi

if [[ ! -d /etc/systemd/system ]]; then
    echo "Systemd directory not found"
    exit 1
fi

systemctl disable auto-update.service &>/dev/null
systemctl disable auto-update.timer &>/dev/null

find /etc/systemd -name 'auto-update.*' -exec rm -f {} \;

if [[ -n $(command -v lsb_release 2>/dev/null) ]]; then
    os_name=$(lsb_release -a | awk -F ':' '$1 == "Distributor ID" {print $2}')
elif [[ -e /etc/os-release ]]; then
    os_name=$(awk -F '=' '$1 == "ID" {print $2}' < /etc/os-release 2>/dev/null)
elif [[ -e /etc/redhat-release ]]; then
    os_name="redhat"
elif [[ -e /etc/fedora-release ]]; then
    os_name="fedora"
elif [[ -e /etc/centos-release ]]; then
    os_name="centos"
else
    os_name="Unknown"
fi

os_name=$(echo "$os_name" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
echo "Operating system: $os_name"

case "$os_name" in
    "centos")
        echo "Installing on CentOS"
		cp auto-update.service /etc/systemd/system
		cp auto-update.timer /etc/systemd/system
		cp -T auto-update.yum /usr/sbin/auto-update
        ;;
    "fedora")
        echo "Installing on Fedora"
		cp auto-update.service /etc/systemd/system
		cp auto-update.timer /etc/systemd/system
		cp -T auto-update.dnf /usr/sbin/auto-update
        ;;
    "red*hat")
        echo "Installing on Red Hat"
		cp auto-update.service /etc/systemd/system
		cp auto-update.timer /etc/systemd/system
		cp -T auto-update.yum /usr/sbin/auto-update
        ;;
    "armbian")
        echo "Installing on Armbian"
		cp auto-update.service /etc/systemd/system
		cp auto-update.timer /etc/systemd/system
		cp -T auto-update.apt /usr/sbin/auto-update
        ;;
    "debian")
        echo "Installing on Debian"
		cp auto-update.service /etc/systemd/system
		cp auto-update.timer /etc/systemd/system
		cp -T auto-update.apt /usr/sbin/auto-update
        ;;
    "raspbian")
        echo "Installing on Raspbian"
		cp auto-update.service /etc/systemd/system
		cp auto-update.timer /etc/systemd/system
		cp -T auto-update.apt /usr/sbin/auto-update
        ;;
    "ubuntu")
        echo "Installing on Ubuntu"
		cp auto-update.service /etc/systemd/system
		cp auto-update.timer /etc/systemd/system
		cp -T auto-update.apt /usr/sbin/auto-update
        ;;
    "zorin")
        echo "Installing on Zorin"
		cp auto-update.service /etc/systemd/system
		cp auto-update.timer /etc/systemd/system
		cp -T auto-update.apt /usr/sbin/auto-update
        ;;
    "linaro")
        echo "Installing on Linaro"
		cp auto-update.service /etc/systemd/system
		cp auto-update.timer /etc/systemd/system
		cp -T auto-update.apt /usr/sbin/auto-update
        ;;
    "sparky")
        echo "Installing on Sparky"
        cp auto-update.service /etc/systemd/system
        cp auto-update.timer /etc/systemd/system
        cp -T auto-update.apt /usr/sbin/auto-update
        ;;
    "opensuse-tumblewee")
        echo "Installing on Tumbleweed"
        cp auto-update.service /etc/systemd/system
        cp auto-update.timer /etc/systemd/system
        cp -T auto-update.zypper /usr/sbin/auto-update
        ;;
    *)
        echo "Unkown operating system"
        exit 1
esac

# Not needed. The timer activates the service.
#if ! systemctl enable auto-update.service; then
#    echo "Failed to enable auto-update.service"
#    exit 1
#fi

if ! systemctl enable auto-update.timer; then
    echo "Failed to enable auto-update.timer"
    exit 1
fi

if ! systemctl start auto-update.timer; then
    echo "Failed to start auto-update.timer"
    exit 1
fi

if ! systemctl daemon-reload 2>/dev/null; then
    echo "Failed to daemon-reload"
fi

if ! systemctl reset-failed; then
    echo "Failed to reset-failed"
fi

echo "Installed services"
exit 0
