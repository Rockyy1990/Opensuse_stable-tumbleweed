#!/usr/bin/env bash

# Skript zur Installation von Linux Mint Wallpaper und Mint-L-Icons auf openSUSE Tumbleweed

# Überprüfen, ob das Skript mit Root-Rechten ausgeführt wird
if [ "$EUID" -ne 0 ]; then
  echo "Bitte das Skript mit Root-Rechten ausführen."
  exit 1
fi

# Aktualisieren der Paketliste
echo "Aktualisiere die Paketliste..."
zypper refresh

# Installieren der benötigten Pakete
echo "Installiere benötigte Pakete..."
zypper install git wget

# Erstellen von Verzeichnissen für Wallpaper und Icons
echo "Erstelle Verzeichnisse für Wallpaper und Icons..."
mkdir -p /usr/share/backgrounds/linuxmint
mkdir -p /usr/share/icons/Mint-L

# Herunterladen der Linux Mint Wallpaper
echo "Lade Linux Mint Wallpaper herunter..."
wget -q -O /tmp/linuxmint-wallpapers.zip https://github.com/linuxmint/linuxmint-wallpapers/archive/refs/heads/master.zip

# Entpacken der Wallpaper
echo "Entpacke Wallpaper..."
unzip -q /tmp/linuxmint-wallpapers.zip -d /tmp/linuxmint-wallpapers

# Kopieren der Wallpaper nach /usr/share/backgrounds/linuxmint
echo "Kopiere Wallpaper nach /usr/share/backgrounds/linuxmint..."
cp /tmp/linuxmint-wallpapers/linuxmint-wallpapers-master/* /usr/share/backgrounds/linuxmint/

# Herunterladen der Mint-L-Icons
echo "Lade Mint-L-Icons herunter..."
git clone https://github.com/linuxmint/mint-l-icons.git /tmp/mint-l-icons

# Kopieren der Icons nach /usr/share/icons/Mint-L
echo "Kopiere Icons nach /usr/share/icons/Mint-L..."
cp -r /tmp/mint-l-icons/* /usr/share/icons/Mint-L/

# Bereinigen der temporären Dateien
echo "Bereinige temporäre Dateien..."
rm -rf /tmp/linuxmint-wallpapers /tmp/linuxmint-wallpapers.zip /tmp/mint-l-icons

# Aktualisieren der Icon-Datenbank
echo "Aktualisiere die Icon-Datenbank..."
gtk-update-icon-cache /usr/share/icons/Mint-L

# Abschlussmeldung
echo "Installation von Linux Mint Wallpaper und Mint-L-Icons abgeschlossen!"