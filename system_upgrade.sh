#!/usr/bin/env bash

echo ""
echo "----------------"
echo "System upgrade.."
echo "  tumbleweed    "
echo "----------------"
sleep 2
sudo zypper refresh
sudo zypper dup -n
sudo zypper rm --clean-deps
sudo zypper clean
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sleep 2
echo ""
read -p "System upgrade is complete. Press any key to reboot"
sudo reboot