#!/bin/bash

# expects a single parameter of temp in C
# example $(tof 47)
function tof() {
    local tf=$(echo "scale=2;((9/5) * $1) + 32" |bc)
    echo "$tf"

}

###### CPU #########
echo "CPU temps"
sensors -f | grep Core


echo -e "\nHD temps"
# find all devices /dev/sd? or /dev/hd?
# for HD in `ls /dev/[sh]d?`
for HD in $(ls /dev/disk/by-id/*ata* | grep -v part)
do

TEMPC=$(smartctl -a $HD | grep -i temperature | awk '{print $10}')
TEMPF=$(tof $TEMPC)
echo -e "$HD\t$TEMPF"F"\t($TEMPC"C")"


done
