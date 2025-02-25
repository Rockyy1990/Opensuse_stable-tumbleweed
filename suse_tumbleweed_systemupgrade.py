#!/usr/bin/env python

import subprocess
import time
import os

def run_command(command):
    """Run a shell command and wait for it to complete."""
    print(f"Running command: {command}")
    subprocess.run(command, shell=True, check=True)

def main():
    print("\n--------------")
    print("System upgrade..")
    print("  tumbleweed    ")
    print("----------------")
    time.sleep(2)

    try:
        run_command("sudo zypper refresh")
        run_command("sudo zypper -n dup")
        run_command("sudo zypper clean")
        run_command("sudo grub2-mkconfig -o /boot/grub2/grub.cfg")
    except subprocess.CalledProcessError as e:
        print(f"An error occurred: {e}")
        return

    time.sleep(2)
    input("System upgrade is complete. Press any key to reboot...")
    run_command("sudo reboot")

if __name__ == "__main__":
    main()