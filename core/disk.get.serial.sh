#!/bin/bash
lshw -class disk | grep -A 2 "$1" | grep serial | sed 's:.*serial\: \(.*\):\1:'
