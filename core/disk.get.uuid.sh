#!/bin/bash

blkid | grep "$1" | sed 's:PARTUUID=\"[0-9a-f-]*\"::' | sed 's:^.*UUID=\"\([0-9a-f-]*\)\".*:\1:'
