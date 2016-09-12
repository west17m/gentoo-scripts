#!/bin/bash
##################################################
#                                                #
# Finds the newest file in a directory           #
#                                                #
##################################################

USAGE="Usage: $0 [dir]"

#if [ $# -ne 1 ]
#then
#  echo -e $USAGE
#  exit 1
#fi

ls -tr $1 | tail -n 1

exit 0

