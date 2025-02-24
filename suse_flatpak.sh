#!/usr/bin/env bash

# Last Edit: 24.02.2025

# Skript zur Installation und Konfiguration von Flatpak
# sowie zur Installation von Bottles und ProtonUp-Qt auf openSUSE Tumbleweed

# Funktion zur Überprüfung, ob ein Befehl erfolgreich war
check_command() {
    if [ $? -ne 0 ]; then
        echo "Fehler: $1"
        exit 1
    fi
}

sudo zypper refresh

# Installation von Flatpak
echo "Installation von Flatpak..."
sudo zypper -n install flatpak

# Hinzufügen des Flathub-Repositorys
echo "Hinzufügen des Flathub-Repositorys..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.github.tchx84.Flatseal

# Installation von Bottles
echo "Installation von Bottles..."
flatpak install -y flathub com.usebottles.bottles

# Installation von ProtonUp-Qt
echo "Installation von ProtonUp-Qt..."
flatpak install -y flathub net.davidotek.pupgui2

echo "Installation und Konfiguration abgeschlossen!"
echo "Bottles und ProtonUp-Qt wurden erfolgreich installiert."