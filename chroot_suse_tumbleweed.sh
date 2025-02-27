#!/usr/bin/env bash

# Chrooting into an openSUSE Tumbleweed installation, especially in a UEFI environment.

# Make sure to replace /dev/sdaX and /dev/sdaY with the actual device names for your root and EFI partitions.
# If you encounter any issues, double-check that you are using the correct partitions and that they are properly mounted.
# If you are performing repairs, ensure you have backups of important data.

read -p "Chrooting into a suse/tumbleweed uefi. 
            Press any key to continue." 


sudo mkdir /mnt/suse
sudo mount /dev/sdaX /mnt/suse  # Replace /dev/sdaX with your root partition

sudo mkdir /mnt/suse/boot/efi
sudo mount /dev/sdaY /mnt/suse/boot/efi  # Replace /dev/sdaY with your EFI partition

sudo mount --bind /dev /mnt/suse/dev
sudo mount --bind /proc /mnt/suse/proc
sudo mount --bind /sys /mnt/suse/sys

sudo chroot /mnt/suse

# Unmount 
# sudo umount /mnt/suse/dev
# sudo umount /mnt/suse/proc
# sudo umount /mnt/suse/sys
# sudo umount /mnt/suse/boot/efi
# sudo umount /mnt/suse