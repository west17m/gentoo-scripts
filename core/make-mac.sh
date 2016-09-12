#!/bin/bash
perl -e 'printf "00:16:3E:%02X:%02X:%02X\n", rand 0xFF, rand 0xFF, rand 0xFF'

