#/bin/bash
# list disks with sn's
echo "Hard disks with serial number, partition location, and size"
lshw -class disk | grep "disk\|size:\|/dev/sd\|serial"

# list the partition UUIDs
echo -e "\nHard disk partitions with encryption.  Partition and UUIDs are listed"
blkid | grep crypto_LUKS | grep PARTLABEL=\"primary\" | sed 's| TYPE=\"crypto_LUKS\" PARTLABEL=\"primary\" PARTUUID=\".*\"||' | sort

# show the currently mapped encrypted partitions
echo -e "\nEncrypted partitions that are currently mapped"
ls -1 /dev/mapper/sn-* | sort

echo -e "\ndisks by id"
ls /dev/disk/by-id/*ata* | grep -v part
