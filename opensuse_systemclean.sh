#!/usr/bin/env bash
echo ""
echo "Opensuse System cleaning script"
echo "This Script must be run with root privileges"
sleep 4
clear


sudo zypper clean
sudo zypper purge-kernels
sudo rm /tmp/* -rf
sudo journalctl --vacuum-time=1d

history -c

exit
