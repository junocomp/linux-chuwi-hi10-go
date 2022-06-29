#!/bin/bash

SUDO_USER=whoami
OS="$(cat /etc/issue | awk 'FNR==1 {print $1}' | sort -u)"
DEBIAN_RELEASE="$(cat /etc/debian_version | awk 'FNR==1 {print $1}' | sort -u)"



echo ""
if [ "$(id -u)" -ne 0 ]; then
	echo "Hello $(whoami | tr 'a-z' 'A-Z')! - Please insert your password to continue."
	exec sudo su -c "bash '$(basename $0)'"
fi

case "$OS" in
    Debian)
    echo "Debian Found!";
    sleep 2;
    
    echo "Enabling systemd-resolved";
    systemctl enable systemd-resolved;
    systemctl start systemd-resolved;
    sleep 1;
    
    echo "Installing iwlwifi";
    apt install ./firmware-iwlwifi-*;
    modprobe iwlwifi;
    sleep 1;
    
    echo "Adding non-free repo";
    sed -e 's/contrib//g' /etc/apt/sources.list;
    sed -e 's/non-free//g' /etc/apt/sources.list;
    sed -i 's/main/main contrib non-free/'g /etc/apt/sources.list;
    apt update;
    sleep 1;
    
    echo "Installing firmware drivers";
    apt install -o Dpkg::Options::="--force-overwrite" firmware-linux-nonfree firmware-intel-sound firmware-sof-signed -y;
    sleep 1;
    
    echo "Installing custom kernel";
    dpkg -i kernel/linux-*;
    sleep 1;
   
    echo "Installing additional packages";
    apt dist-upgrade -y;
    apt install -o Dpkg::Options::="--force-overwrite" plocate dconf-editor youtube-dl lsb-release qtwayland5 fonts-open-sans ffmpeg libavcodec58 gstreamer1.0-gl mesa-va-drivers mesa-vulkan-drivers git curl powersupply network-manager-config-connectivity-debian linux-cpupower intel-media-va-driver-non-free thermald pulseaudio-module-gsettings bolt acpid flatpak openssh-server irqbalance -y;
    
    dpkg -s gnome-control-center &> /dev/null;
    if [ $? -eq 0 ]; then;
    apt install power-profiles-daemon gnome-software-plugin-flatpak -y;
    fi;
    
    apt purge --remove tilix -y;
    apt autoremove -y;
    sysmtectl enable irqbalance.service;
    sysmtectl enable thermald.service;
    sleep 1;
    
    ;;
    Ubuntu)
    echo "Debian Found!";
    sleep 2;
    
    echo "Installing custom kernel";
    dpkg -i kernel/linux-*;
    sleep 1;
    
    echo "Upgrading Packages";
    apt update;
    apt dist-upgrade -y;
    apt install -o Dpkg::Options::="--force-overwrite" flatpak gnome-software-plugin-flatpak firmware-sof-signed irqbalance -y;
    sleep 1;
    
    ;;
    *)
    echo "Optimizing Turbo";
    cd turbo;
    cp juno-turbo.rules /etc/udev/rules.d/;
    chmod a+x turbo-off turbo-on turbo-stat;
    cp turbo-* /usr/bin;
    cd ..;
    chmod a+x check-battery
    cp check-battery /usr/bin
    sleep 1;
    
    echo "Optimizing WIFI Powersave";
    cp 70-wifi-pm.rules /etc/udev/rules.d/;
    sleep 1;
    
    echo "Installing Alsa systemd";
    chmod a+x alsa/restore-alsa;
    cp alsa/restore-alsa /usr/bin;
    cp restore-alsa.service /etc/systemd/system;
    systemctl enable restore-alsa.service;
    systemctl start restore-alsa.service;
    sleep 1;
    
    echo "Additing Flathub Repo";
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo;
    sleep 1;
    
    ;;
esac
