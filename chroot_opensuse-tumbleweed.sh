#!/usr/bin/env bash

set -e  # Beende das Skript bei einem Fehler

# Funktion zum Chrooten
chroot_into_system() {
    local root_partition="$1"
    local efi_partition="$2"

    # Überprüfen, ob die Root-Partition existiert
    if [ ! -b "$root_partition" ]; then
        echo "Fehler: Die Root-Partition $root_partition existiert nicht."
        exit 1
    fi

    # Mounten der Root-Partition
    mount "$root_partition" /mnt

    # Mounten der EFI-Partition, falls vorhanden
    if [ -n "$efi_partition" ]; then
        if [ ! -b "$efi_partition" ]; then
            echo "Fehler: Die EFI-Partition $efi_partition existiert nicht."
            cleanup
            exit 1
        fi
        mkdir -p /mnt/boot/efi
        mount "$efi_partition" /mnt/boot/efi
    fi

    # Bind-Mount für /dev, /proc und /sys
    mount --bind /dev /mnt/dev
    mount --bind /proc /mnt/proc
    mount --bind /sys /mnt/sys

    # Chroot in das System
    echo "Wechsel in die Chroot-Umgebung..."
    chroot /mnt /bin/bash

    # Nach dem Verlassen des Chroots unmounten
    cleanup
}

# Funktion zum Aufräumen
cleanup() {
    echo "Unmounting partitions..."
    umount /mnt/dev || true
    umount /mnt/proc || true
    umount /mnt/sys || true
    umount /mnt/boot/efi || true
    umount /mnt || true
    echo "Cleanup done."
}

# Hauptmenü
while true; do
    echo "=============================="
    echo " Chroot Menu for openSUSE Tumbleweed"
    echo "=============================="
    echo "1. Chroot into system"
    echo "2. Exit"
    echo -n "Please select an option: "
    read -r option

    case $option in
        1)
            echo -n "Enter the root partition (e.g. /dev/sda2): "
            read -r root_partition
            echo -n "Enter the EFI partition (e.g. /dev/sda1, or leave empty if not applicable): "
            read -r efi_partition
            chroot_into_system "$root_partition" "$efi_partition"
            ;;
        2)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
done