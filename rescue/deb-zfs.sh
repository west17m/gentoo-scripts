#!/bin/bash
# this script take a server booted into the Hetzner Rescue System
# and sets up with ZFS

ZPOOL_NAME="tank"

# just in case, stop raid devices
mdadm --stop /dev/md*


# see https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation
# http://www.funtoo.org/ZFS_Install_Guide

set -e on

wget http://archive.zfsonlinux.org/debian/pool/main/z/zfsonlinux/zfsonlinux_6_all.deb
dpkg -i zfsonlinux_6_all.deb
apt-get update
apt-get -y install lsb-release
apt-get -y install debian-zfs lshw
modprobe zfs
