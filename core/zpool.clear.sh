#!/bin/bash

DEV="$1"
CLEAN_DEV=`echo $DEV | sed 's:.*sn-WD-::'`

# save information before clearing message
echo -e "$DEV\t"`date` >> /root/zpool.history.txt
zpool status >> /root/zpool.history.txt

# clear message
zpool clear tank "$DEV"

# show smartd results
echo "errors reset, here are the pertenent logs"
cat /var/log/messages | grep $CLEAN_DEV
cat /var/log/messages | grep $CLEAN_DEV >> /root/zpool.history.txt

