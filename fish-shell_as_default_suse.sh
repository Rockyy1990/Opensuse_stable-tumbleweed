#!/bin/bash

# Überprüfen, ob das Skript mit Root-Rechten ausgeführt wird
if [ "$EUID" -ne 0 ]; then
  echo "Bitte das Skript als Root oder mit sudo ausführen."
  exit 1
fi

# Fish installieren
echo "Installiere Fish..."
zypper install -y fish

# Fish als Standard-Shell für alle Benutzer festlegen
echo "Setze Fish als Standard-Shell für alle Benutzer..."
for user in $(cut -f1 -d: /etc/passwd); do
  chsh -s /usr/bin/fish "$user" 2>/dev/null
done

# Überprüfen, ob die Änderung erfolgreich war
echo "Überprüfe die Standard-Shell für alle Benutzer..."
for user in $(cut -f1 -d: /etc/passwd); do
  shell=$(getent passwd "$user" | cut -d: -f7)
  if [ "$shell" == "/usr/bin/fish" ]; then
    echo "Benutzer $user hat jetzt Fish als Standard-Shell."
  else
    echo "Benutzer $user hat nicht Fish als Standard-Shell."
  fi
done

# Fish-Konfiguration für neue Benutzer erstellen
echo "Erstelle Standard-Fish-Konfigurationsdatei..."
if [ ! -d /etc/fish ]; then
  mkdir -p /etc/fish
fi

if [ ! -f /etc/fish/config.fish ]; then
  echo "# Standard-Fish-Konfiguration" > /etc/fish/config.fish
  echo "set -gx PATH \$PATH" >> /etc/fish/config.fish
  echo "alias ll='ls -la'" >> /etc/fish/config.fish
  echo "alias gs='git status'" >> /etc/fish/config.fish
fi

echo "Fish wurde erfolgreich installiert und als Standard-Shell festgelegt."
echo "Bitte melden Sie sich ab und wieder an, um die Änderungen zu übernehmen."