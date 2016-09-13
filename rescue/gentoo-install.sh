#!/bin/bash

ZPOOL_NAME="tank"
EMERGE="emerge --jobs=4 --load-average=8 --keep-going=y -v"

# see https://www.gentoo.org/downloads/
STAGE3="http://distfiles.gentoo.org/releases/amd64/autobuilds/20160908/hardened/stage3-amd64-hardened-20160908.tar.bz2"

TIMEZONE="US/Central"
LOCALE="en_US" # or "en_US.utf8"

# run this if you have a new zpool and are ready to install gentoo
function prep_zpool() {
  # basic directory structure
  zfs create -o mountpoint=none  "$ZPOOL_NAME"/gentoo
  zfs create -o mountpoint=/     "$ZPOOL_NAME"/gentoo/root
  zfs create -o mountpoint=/home "$ZPOOL_NAME"/gentoo/root/home

  # swap
  zfs create -o sync=always -o primarycache=metadata -o secondarycache=none -b 4k -V 4G -o logbias=throughput tank/swap
  mkswap -f /dev/zvol/tank/swap
  swapon /dev/zvol/tank/swap

  # set boot params
  zpool set bootfs="$ZPOOL_NAME"/gentoo/root "$ZPOOL_NAME"/gentoo/root

  zfs list

  echo "Please check the above and then proceed with install"
}

function doinstall() {
  set -e on
  cd /mnt/gentoo
  wget "$STAGE3"
  tar xjpf stage3-*.tar.bz2 --xattrs
  mkdir /mnt/gentoo/etc/portage/repos.conf
  cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
  cp -L /etc/resolv.conf /mnt/gentoo/etc/
  mkdir -p /mnt/gentoo/etc/zfs
  cp /tmp/zpool.cache /mnt/gentoo/etc/zfs/zpool.cache

  mount -t proc proc /mnt/gentoo/proc
  mount --rbind /sys /mnt/gentoo/sys
  mount --make-rslave /mnt/gentoo/sys
  mount --rbind /dev /mnt/gentoo/dev
  mount --make-rslave /mnt/gentoo/dev

  echo -e "files have installed to the system\nplease proceed by copying this program to /mnt/gentoo/root\nand running chroot1"
}

function chroot1() {
  echo "chroot /mnt/gentoo /bin/bash"
  echo "env-update && source /etc/profile && export PS1=\"(chroot) $PS1\""
  echo "proceed with chroot2 inside the new environment"
}

function chroot2() {
  # Bootstrap the portage tree
  wget http://xyinn.org/gentoo/portage/portage-snapshot.tar.xz
  tar xf portage-snapshot.tar.xz -C /usr/

  # or you could emerge --sync --quiet

  echo "$TIMEZONE" > /etc/timezone
  emerge --config sys-libs/timezone-data

  sed -i.bak 's:^#en_US:en_US:' /etc/locale.gen
  locale-gen
  eselect locale set "$LOCALE"

  env-update && source /etc/profile && export PS1="(chroot) $PS1"

  # I don't like portage directories
  cat /etc/portage/package.keywords/* > /tmp/package.keywords
  rm -rf /etc/portage/package.keywords 
  mv /tmp/package.keywords /etc/portage
  ln /etc/portage/package.keywords /etc/portage/package.accept_keywords

  cat /etc/portage/package.mask/* > /tmp/package.mask && \
  rm -rf /etc/portage/package.mask && \
  mv /tmp/package.mask /etc/portage

  cat /etc/portage/package.use/* > /tmp/package.use && \
  rm -rf /etc/portage/package.use && \
  mv /tmp/package.use /etc/portage

  cat >> /etc/portage/package.accept_keywords <<EOL
sys-boot/grub ~amd64
sys-kernel/spl ~amd64
sys-fs/zfs ~amd64
sys-fs/zfs-kmod ~amd64
EOL
  cat >> /etc/portage/package.use <<EOL
dev-libs/libgcrypt static-libs
dev-libs/libgpg-error static-libs
dev-libs/popt static-libs
sys-apps/util-linux static-libs
sys-boot/grub libzfs device-mapper
sys-fs/cryptsetup static-libs
sys-fs/eudev static-libs
sys-fs/lvm2 static-libs
sys-kernel/bliss-initramfs luks lvm raid zfs
virtual/libudev static-libs
EOL

$EMERGE hardened-sources genkernel
genkernel --oldconfig --install --makeopts=-j9 --no-mountboot kernel

# zfs depends on spl which need the kernel to be compiled
$EMERGE sys-fs/zfs grub net-misc/dhcpcd
genkernel --zfs --no-clean --no-mountboot initramfs

echo "run chroot3"

}

function chroot3 {
  NEWHOST="s5"

  echo 'modules="igb"' >> /etc/conf.d/modules
  echo -e "/dev/zvol/tank/swap\tnone\tswap\tsw\t0 0" > /etc/fstab
  echo "hostname=\"$NEWHOST\"" > /etc/conf.d/hostname
  echo 'config_eth0="dhcp"' > /etc/conf.d/net
  cd /etc/init.d
  ln -s net.lo net.eth0
  rc-update add net.eth0 default
  rc-update add sshd default
  echo "PermitRootLogin Yes" >> /etc/ssh/sshd_config
  echo "time to set a root password"
  passwd

}
