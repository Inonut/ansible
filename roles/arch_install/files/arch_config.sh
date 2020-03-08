#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e
# Print commands and their arguments as they are executed.
#set -x

boot_device=$1
boot_mnt_path=$2
hostname=$3
password=$4
timezone=$5

#### Config Arch Linux ####
# Allow searching for packages in all mirrorlist
cat <<EOF >> /etc/pacman.conf
[multilib]
Include = /etc/pacman.d/mirrorlist
EOF
pacman --noconfirm -Sy

# Create an initial ramdisk environmen (https://wiki.archlinux.org/index.php/Mkinitcpio)
mkinitcpio -p linux

# Config grub (https://wiki.archlinux.org/index.php/GRUB)
mkdir -p "${boot_mnt_path}"
mount "${boot_device}" "${boot_mnt_path}"
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory="${boot_mnt_path}"
grub-mkconfig -o /boot/grub/grub.cfg

# Config host name and network (https://wiki.archlinux.org/index.php/Network_configuration)
cat <<EOF >> /etc/hostname
$hostname
EOF
cat <<EOF >> /etc/hosts
127.0.0.1	localhost
::1		    localhost
127.0.1.1	$hostname.localdomain	$hostname
EOF

# Enable network
systemctl enable NetworkManager.service

# Config keybourd language
cat <<EOF >> /etc/locale.gen
en_US.UTF-8 UTF-8
en_US ISO-8859-1
EOF
cat <<EOF >> /etc/locale.conf
LANG=en_US.UTF-8
EOF
locale-gen

# Config PC time
ln -sf "/usr/share/zoneinfo/$timezone" /etc/localtime
hwclock --systohc --utc

# Add root password
echo -en "$password\n$password" | passwd