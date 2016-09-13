#!/bin/bash
# this script take a server booted into the Hetzner Rescue System
# and sets up with ZFS

ZPOOL_NAME="tank"

# just in case, stop raid devices
mdadm --stop /dev/md*


# see https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation
# http://www.funtoo.org/ZFS_Install_Guide

set -e on

modprobe zfs

set -e off
for DEVICE in /dev/sd?
do
  smartctl -s on "$DEVICE"
  sgdisk -Z "$DEVICE"                             # wipe partition info
  dd if=/dev/zero of="$DEVICE" bs=512 count=4096  # overwrite MBR
  # parted -a optimal "$DEVICE" --script -- mklabel gpt
  # parted -a optimal "$DEVICE" --script -- unit MiB mkpart primary 1 -1
  # parted -a optimal "$DEVICE" --script -- align-check optimal 1
  # parted -a optimal "$DEVICE" --script -- unit MiB print
done

set -e on
zpool create -f \
  -o ashift=12 \
  -o cachefile=/tmp/zpool.cache \
  -O normalization=formD \
  -m none \
  -R /mnt/gentoo -d \
  -o feature@async_destroy=enabled \
  -o feature@empty_bpobj=enabled \
  -o feature@lz4_compress=enabled \
  -o feature@spacemap_histogram=enabled \
  -o feature@enabled_txg=enabled \
  -o feature@extensible_dataset=enabled \
  -o feature@bookmarks=enabled \
  "$ZPOOL_NAME" \
  mirror /dev/sd?

for DEVICE in /dev/sd?
do
  sgdisk --new=2:48:2047 --typecode=2:EF02 --change-name=2:"BIOS boot partition" "$DEVICE"
  sleep 1s
  partprobe "$DEVICE"
done

parted -l
zpool status
zfs list
