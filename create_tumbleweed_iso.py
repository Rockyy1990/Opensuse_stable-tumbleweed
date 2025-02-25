#!/usr/bin/env python3

import os
import subprocess

# Variablen
ISO_NAME = "openSUSE-Tumbleweed-Live.iso"
WORK_DIR = "/tmp/opensuse-live"
OSS_REPO_URL = "http://download.opensuse.org/tumbleweed/repo/oss/"
NON_OSS_REPO_URL = "http://download.opensuse.org/tumbleweed/repo/non-oss/"
PACKAGE_LIST = "pattern:base, pattern:desktop, pattern:openSUSE-Desktop, vim, gedit, firefox, gimp, networkmanager"

# Funktion zum Installieren der benötigten Pakete
def install_packages():
    print("Installiere benötigte Pakete...")
    try:
        subprocess.run(["sudo","zypper","-n", "install", "python3-kiwi"], check=True)
    except subprocess.CalledProcessError:
        print("Fehler beim Installieren von kiwi.")
        exit(1)

# Funktion zum Hinzufügen der Repositories
def add_repositories():
    print("Füge Repositories hinzu...")
    subprocess.run(["zypper", "ar", "-f", OSS_REPO_URL, "openSUSE-Tumbleweed-OSS"], check=True)
    subprocess.run(["zypper", "ar", "-f", NON_OSS_REPO_URL, "openSUSE-Tumbleweed-NON-OSS"], check=True)
    subprocess.run(["zypper", "refresh"], check=True)

# Funktion zum Erstellen der Live-ISO
def create_live_iso():
    print("Erstelle Live-ISO...")

    # Erstelle das Arbeitsverzeichnis
    os.makedirs(WORK_DIR, exist_ok=True)

    # Erstelle die Konfigurationsdatei für KIWI
    config_content = f"""<image type="live">
    <description>openSUSE Tumbleweed Live ISO</description>
    <version>1.0</version>
    <release>1</release>
    <source>
        <repository>
            <url>{OSS_REPO_URL}</url>
        </repository>
        <repository>
            <url>{NON_OSS_REPO_URL}</url>
        </repository>
    </source>
    <packages>
        <package>{PACKAGE_LIST}</package>
    </packages>
    <boot>
        <loader>grub2</loader>
        <timeout>5</timeout>
    </boot>
    <user>
        <name>liveuser</name>
        <password>live</password>
        <home>/home/liveuser</home>
        <groups>users, wheel</groups>
    </user>
</image>"""

    with open(os.path.join(WORK_DIR, "config.xml"), "w") as config_file:
        config_file.write(config_content)

    # Erstelle die ISO mit KIWI
    try:
        subprocess.run(["kiwi", "--build", os.path.join(WORK_DIR, "config.xml"), "--iso"], check=True)
    except subprocess.CalledProcessError:
        print("Fehler beim Erstellen der ISO.")
        cleanup()
        exit(1)

    # Verschiebe die ISO in das aktuelle Verzeichnis
    os.rename(os.path.join(WORK_DIR, "*.iso"), os.path.join(".", ISO_NAME))

    print(f"Live-ISO wurde erstellt: {ISO_NAME}")

# Funktion zum Aufräumen
def cleanup():
    print("Aufräumen...")
    if os.path.exists(WORK_DIR):
        os.rmdir(WORK_DIR)

# Hauptprogramm
print("==============================")
print(" Erstelle openSUSE Tumbleweed Live ISO")
print("==============================")

# Installiere die benötigten Pakete
install_packages()

# Füge die Repositories hinzu
add_repositories()

# Erstelle die Live-ISO
create_live_iso()

# Aufräumen
cleanup()

print("Fertig!")
