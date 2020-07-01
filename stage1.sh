#!/bin/bash -xv

set -eo pipefail

LOOP="/dev/sda"
ROOT="/dev/sda1"

VERSION="1.11.0"

sudo umount root || true

sudo rm -fR root kiss-chroot* kiss.img
mkdir root

wget https://github.com/kisslinux/repo/releases/download/${VERSION}/kiss-chroot.tar.xz
wget https://raw.githubusercontent.com/kisslinux/kiss/master/contrib/kiss-chroot
chmod 755 kiss-chroot

wget https://github.com/kisslinux/repo/releases/download/${VERSION}/kiss-chroot.tar.xz.sha256
sha256sum -c < kiss-chroot.tar.xz.sha256

fdisk /dev/sda <<EOF
o
n
p
1


a
w
EOF

sudo mkfs.ext4 $ROOT
sudo mount $ROOT root

sudo tar xf kiss-chroot.tar.xz -C root --strip-components 1

sudo cp stage2.sh root/

printf "Run ./stage2.sh in the chroot...\n"

sudo ./kiss-chroot ./root

sudo umount root

printf "Success!\n"
