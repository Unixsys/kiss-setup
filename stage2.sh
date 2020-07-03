#!/bin/sh

LOOP="/dev/sda"

set -eo pipefail

echo | kiss update
echo | kiss update
echo | kiss build $(ls /var/db/kiss/installed)

for pkg in e2fsprogs dosfstools util-linux eudev dhcpcd libelf ncurses perl; do
  echo | kiss build $pkg
  kiss install $pkg
done

cd /dev/shm
git clone https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/
mkdir -p /usr/lib/firmware
cd linux-firmware
for i in $(ls); do
[ -d $i ] && cd $i && mv * ../ && cd - && rm -r $i && continue
done
for i in $(ls); do
mv $i /usr/lib/firmware
done

KERNEL_VERSION="5.6.14"
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-${KERNEL_VERSION}.tar.xz
tar xf linux-${KERNEL_VERSION}.tar.xz
cd linux-${KERNEL_VERSION}

#|   DOWNLOAD FIRMWARE BLOBS (if required)                       |
#|                                                               |
#|   To keep the KISS repositories entirely FOSS, the            |
#|   proprietary kernel firmware is omitted. This also           |
#|   makes sense as the kernel itself is manually managed        |
#|   by the user.                                                |
#|                                                               |
#|   Note: This step is only required if your hardware           |
#|   utilizes these drivers.                                     |
#|                                                               |
#|   Sources: kernel.org                                         |
#|                                                               |
#|   # Download and extract the firmware.                        |
#$   wget FIRMWARE_TARBALL.tar.gz                                |
#$   tar xvf linux-firmware-20191022.tar.gz                      |
#|                                                               |
#|   # Copy the required drivers to '/usr/lib/firmware'.         |
#$   mkdir -p /usr/lib/firmware                                  |
#$   cp -R ./path/to/driver /usr/lib/firmware                    |
#|                                                               |
#|                                                               |

make defconfig
make -j $(nproc)
make modules_install
make install

mv /boot/vmlinuz /boot/vmlinuz-${KERNEL_VERSION}
mv /boot/System.map /boot/System-map-${KERNEL_VERSION}

cd ..

rm -fR linux-${KERNEL_VERSION}*

printf '\n' | kiss build grub
kiss install grub

grub-install $LOOP
grub-mkconfig -o /boot/grub/grub.cfg

printf '\n' | kiss build baseinit
kiss install baseinit

rm stage2.sh
rm -r /root/.cache

printf "Exit chroot\n"
