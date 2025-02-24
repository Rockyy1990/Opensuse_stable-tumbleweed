#!/bin/bash

# Überprüfen, ob das Skript mit Root-Rechten ausgeführt wird
if [ "$EUID" -ne 0 ]; then
  echo "Bitte das Skript als Root oder mit sudo ausführen."
  exit 1
fi

# Zsh installieren
echo "Installiere Zsh..."
zypper install -n zsh

# Zsh als Standard-Shell für alle Benutzer festlegen
echo "Setze Zsh als Standard-Shell für alle Benutzer..."
for user in $(cut -f1 -d: /etc/passwd); do
  chsh -s /usr/bin/zsh "$user" 2>/dev/null
done

# Überprüfen, ob die Änderung erfolgreich war
echo "Überprüfe die Standard-Shell für alle Benutzer..."
for user in $(cut -f1 -d: /etc/passwd); do
  shell=$(getent passwd "$user" | cut -d: -f7)
  if [ "$shell" == "/usr/bin/zsh" ]; then
    echo "Benutzer $user hat jetzt Zsh als Standard-Shell."
  else
    echo "Benutzer $user hat nicht Zsh als Standard-Shell."
  fi
done

# Zsh-Konfiguration für neue Benutzer erstellen
echo "Erstelle Standard-Zsh-Konfigurationsdatei..."
if [ ! -f /etc/zsh/zshrc ]; then
  cp /etc/zsh/zshrc /etc/zsh/zshrc.bak
  echo "# Standard-Zsh-Konfiguration" > /etc/zsh/zshrc
  echo "export PATH=\$PATH" >> /etc/zsh/zshrc
  echo "alias ll='ls -la'" >> /etc/zsh/zshrc
  echo "alias gs='git status'" >> /etc/zsh/zshrc
fi

echo "Zsh wurde erfolgreich installiert und als Standard-Shell festgelegt."
echo "Bitte melden Sie sich ab und wieder an, um die Änderungen zu übernehmen."