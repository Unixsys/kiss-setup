#!/bin/bash -xv

set -eo pipefail

LOOP="/dev/sda"
ROOT="/dev/sda1"

VERSION="1.11.0"

umount root || true

rm -fR root kiss-chroot*
mkdir root

wget https://github.com/kisslinux/repo/releases/download/${VERSION}/kiss-chroot.tar.xz
wget https://raw.githubusercontent.com/kisslinux/kiss/master/contrib/kiss-chroot
chmod 755 kiss-chroot

wget https://github.com/kisslinux/repo/releases/download/${VERSION}/kiss-chroot.tar.xz.sha256
sha256sum -c < kiss-chroot.tar.xz.sha256

fdisk $LOOP <<EOF
o
n
p
1


a
w
EOF

mkfs.ext4 $ROOT
mount $ROOT root

tar xf kiss-chroot.tar.xz -C root --strip-components 1

cp stage2.sh root/

printf "Run ./stage2.sh\n"

./kiss-chroot ./root

umount root
