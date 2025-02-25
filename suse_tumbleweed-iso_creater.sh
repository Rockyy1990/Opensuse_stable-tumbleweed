#!/usr/bin/env bash

# Last Edit: 25.02.2025


set -e  # Beende das Skript bei einem Fehler

# Variablen
ISO_NAME="openSUSE-Tumbleweed-Live.iso"
WORK_DIR="/tmp/opensuse-live"
OSS_REPO_URL="http://download.opensuse.org/tumbleweed/repo/oss/"
NON_OSS_REPO_URL="http://download.opensuse.org/tumbleweed/repo/non-oss/"
PACKAGE_LIST="pattern:base, pattern:desktop, pattern:openSUSE-Desktop, vim, gedit, firefox, gimp, networkmanager"

# Funktion zum Installieren der benötigten Pakete
install_packages() {
    echo "Installiere benötigte Pakete..."
    if ! sudo zypper -n install python3-kiwi; then
        echo "Fehler beim Installieren von kiwi."
        exit 1
    fi
}

# Funktion zum Hinzufügen der Repositories
add_repositories() {
    echo "Füge Repositories hinzu..."
    sudo zypper ar -f "$OSS_REPO_URL" "openSUSE-Tumbleweed-OSS"
    sudo zypper ar -f "$NON_OSS_REPO_URL" "openSUSE-Tumbleweed-NON-OSS"
    sudo zypper refresh
}

# Funktion zum Erstellen der Live-ISO
create_live_iso() {
    echo "Erstelle Live-ISO..."

    # Erstelle das Arbeitsverzeichnis
    mkdir -p "$WORK_DIR"

    # Erstelle die Konfigurationsdatei für KIWI
    cat <<EOF > "$WORK_DIR/config.xml"
<image type="live">
    <description>openSUSE Tumbleweed Live ISO</description>
    <version>1.0</version>
    <release>1</release>
    <source>
        <repository>
            <url>$OSS_REPO_URL</url>
        </repository>
        <repository>
            <url>$NON_OSS_REPO_URL</url>
        </repository>
    </source>
    <packages>
        <package>$PACKAGE_LIST</package>
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
</image>
EOF

    # Erstelle die ISO mit KIWI
    if ! kiwi --build "$WORK_DIR/config.xml" --iso; then
        echo "Fehler beim Erstellen der ISO."
        cleanup
        exit 1
    fi

    # Verschiebe die ISO in das aktuelle Verzeichnis
    mv "$WORK_DIR/*.iso" ./"$ISO_NAME"

    echo "Live-ISO wurde erstellt: $ISO_NAME"
}

# Funktion zum Aufräumen
cleanup() {
    echo "Aufräumen..."
    rm -rf "$WORK_DIR"
}

# Hauptprogramm
echo "=============================="
echo " Erstelle openSUSE Tumbleweed Live ISO"
echo "=============================="

# Installiere die benötigten Pakete
install_packages

# Füge die Repositories hinzu
add_repositories

# Erstelle die Live-ISO
create_live_iso

# Aufräumen
cleanup

echo "Fertig!"
