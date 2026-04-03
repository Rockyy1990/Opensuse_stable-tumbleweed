#!/bin/bash

# ==============================================================
#  openSUSE Tumbleweed Package Manager
#  Paketverwaltung, Repositories, Systeminfo & Dienste
# ==============================================================

# Farben definieren
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# ============================================================
# Hilfsfunktionen
# ============================================================
print_header() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}   openSUSE Tumbleweed Package Manager${CYAN}   ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo ""
}

print_error() {
    echo -e "${RED}✗ Fehler: $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_section() {
    echo -e "${MAGENTA}── $1 ──${NC}"
    echo ""
}

check_exit() {
    if [ $? -eq 0 ]; then
        print_success "$1"
    else
        print_error "$2"
    fi
}

# ============================================================
# ZYPPER Menü
# ============================================================
zypper_menu() {
    while true; do
        print_header
        echo -e "${YELLOW}=== ZYPPER PAKETMANAGER MENÜ ===${NC}"
        echo ""
        echo -e "${GREEN}1)${NC}  Verfügbare Updates prüfen"
        echo -e "${GREEN}2)${NC}  Pakete installieren"
        echo -e "${GREEN}3)${NC}  Pakete entfernen"
        echo -e "${GREEN}4)${NC}  Nach Paketen suchen"
        echo -e "${GREEN}5)${NC}  Paketinformationen anzeigen"
        echo -e "${GREEN}6)${NC}  Paketdateien auflisten (rpm -ql)"
        echo -e "${GREEN}7)${NC}  System aktualisieren (zypper dup)"
        echo -e "${GREEN}8)${NC}  Sicherheitsupdates einspielen"
        echo -e "${GREEN}9)${NC}  Paket-Lock verwalten"
        echo -e "${GREEN}10)${NC} Zypper Reparatur & Wartung"
        echo -e "${GREEN}11)${NC} Zurück zum Hauptmenü"
        echo ""
        read -p "Wähle eine Option [1-11]: " choice

        case $choice in
            1)
                print_header
                print_section "Verfügbare Updates"
                print_info "Prüfe verfügbare Updates..."
                sudo zypper list-updates
                echo ""
                count=$(sudo zypper list-updates 2>/dev/null | grep "^v " | wc -l)
                print_info "Verfügbare Updates: ${WHITE}$count${NC}"
                read -p "Drücke Enter um fortzufahren..."
                ;;
            2)
                print_header
                print_section "Pakete installieren"
                read -p "Paketname(n) eingeben (durch Leerzeichen trennen): " packages
                if [ -z "$packages" ]; then
                    print_error "Keine Pakete eingegeben"
                else
                    print_info "Installiere: $packages"
                    sudo zypper install $packages
                    check_exit "Pakete erfolgreich installiert" "Fehler beim Installieren"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            3)
                print_header
                print_section "Pakete entfernen"
                read -p "Paketname(n) eingeben (durch Leerzeichen trennen): " packages
                if [ -z "$packages" ]; then
                    print_error "Keine Pakete eingegeben"
                else
                    print_warning "Entferne: $packages"
                    sudo zypper remove $packages
                    check_exit "Pakete erfolgreich entfernt" "Fehler beim Entfernen"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            4)
                print_header
                print_section "Pakete suchen"
                read -p "Suchbegriff eingeben: " search_term
                if [ -z "$search_term" ]; then
                    print_error "Kein Suchbegriff eingegeben"
                else
                    print_info "Suche nach: $search_term"
                    zypper search "$search_term"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            5)
                print_header
                print_section "Paketinformationen"
                read -p "Paketname eingeben: " package
                if [ -z "$package" ]; then
                    print_error "Kein Paket eingegeben"
                else
                    print_info "Informationen für: $package"
                    zypper info "$package"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            6)
                print_header
                print_section "Paketdateien auflisten"
                read -p "Paketname eingeben: " package
                if [ -z "$package" ]; then
                    print_error "Kein Paket eingegeben"
                else
                    if rpm -q "$package" &>/dev/null; then
                        print_info "Dateien des Pakets '$package':"
                        rpm -ql "$package"
                    else
                        print_warning "Paket '$package' ist nicht installiert"
                        print_info "Suche im Repository..."
                        zypper search --provides "$package"
                    fi
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            7)
                print_header
                print_section "Distributionsupgrade (zypper dup)"
                print_warning "zypper dup aktualisiert das komplette System (Tumbleweed)"
                print_info "Dies kann einige Zeit dauern und erfordert einen Neustart"
                echo ""
                read -p "Fortfahren? (j/N): " confirm
                if [[ $confirm == "j" || $confirm == "J" ]]; then
                    print_info "Führe zypper dup durch..."
                    sudo zypper dist-upgrade
                    check_exit "Systemupgrade erfolgreich abgeschlossen" "Fehler beim Systemupgrade"
                    echo ""
                    read -p "System jetzt neu starten? (j/N): " reboot_now
                    if [[ $reboot_now == "j" || $reboot_now == "J" ]]; then
                        print_info "System wird in 5 Sekunden neu gestartet..."
                        sleep 5
                        sudo reboot
                    fi
                else
                    print_info "Abgebrochen"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            8)
                print_header
                print_section "Sicherheitsupdates"
                print_info "Zeige verfügbare Sicherheitsupdates..."
                sudo zypper list-patches --category security
                echo ""
                read -p "Sicherheitsupdates jetzt installieren? (j/N): " confirm
                if [[ $confirm == "j" || $confirm == "J" ]]; then
                    sudo zypper patch --category security
                    check_exit "Sicherheitsupdates erfolgreich installiert" "Fehler bei den Sicherheitsupdates"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            9)
                zypper_lock_menu
                ;;
            10)
                zypper_repair_menu
                ;;
            11)
                return
                ;;
            *)
                print_error "Ungültige Option"
                sleep 1
                ;;
        esac
    done
}

# ============================================================
# Zypper Paket-Lock Menü
# ============================================================
zypper_lock_menu() {
    while true; do
        print_header
        echo -e "${YELLOW}=== PAKET-LOCK VERWALTUNG ===${NC}"
        echo ""
        echo -e "${GREEN}1)${NC} Alle gesperrten Pakete anzeigen"
        echo -e "${GREEN}2)${NC} Paket sperren (Update verhindern)"
        echo -e "${GREEN}3)${NC} Paket entsperren"
        echo -e "${GREEN}4)${NC} Zurück zum Zypper-Menü"
        echo ""
        read -p "Wähle eine Option [1-4]: " choice

        case $choice in
            1)
                print_header
                print_section "Gesperrte Pakete"
                sudo zypper locks
                read -p "Drücke Enter um fortzufahren..."
                ;;
            2)
                print_header
                read -p "Paketname eingeben: " package
                if [ -z "$package" ]; then
                    print_error "Kein Paket eingegeben"
                else
                    sudo zypper addlock "$package"
                    check_exit "Paket '$package' gesperrt" "Fehler beim Sperren"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            3)
                print_header
                print_info "Aktuell gesperrte Pakete:"
                sudo zypper locks
                echo ""
                read -p "Paketname eingeben: " package
                if [ -z "$package" ]; then
                    print_error "Kein Paket eingegeben"
                else
                    sudo zypper removelock "$package"
                    check_exit "Sperre für '$package' aufgehoben" "Fehler beim Entsperren"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            4)
                return
                ;;
            *)
                print_error "Ungültige Option"
                sleep 1
                ;;
        esac
    done
}

# ============================================================
# Zypper Reparatur & Wartung Menü
# ============================================================
zypper_repair_menu() {
    while true; do
        print_header
        echo -e "${RED}=== ZYPPER REPARATUR & WARTUNG ===${NC}"
        echo ""
        echo -e "${GREEN}1)${NC}  Repositories aktualisieren (zypper refresh)"
        echo -e "${GREEN}2)${NC}  Paketdatenbank überprüfen (zypper verify)"
        echo -e "${GREEN}3)${NC}  Abhängigkeiten reparieren"
        echo -e "${GREEN}4)${NC}  Verwaiste Pakete entfernen (zypper packages --orphaned)"
        echo -e "${GREEN}5)${NC}  RPM-Datenbank neu aufbauen"
        echo -e "${GREEN}6)${NC}  Zypper-Cache leeren"
        echo -e "${GREEN}7)${NC}  Paket neu installieren"
        echo -e "${GREEN}8)${NC}  Duplikate entfernen"
        echo -e "${GREEN}9)${NC}  Vollständige Systemreparatur"
        echo -e "${GREEN}10)${NC} Zypper-Konfiguration anzeigen"
        echo -e "${GREEN}11)${NC} Zurück zum Zypper-Menü"
        echo ""
        read -p "Wähle eine Option [1-11]: " choice

        case $choice in
            1)
                print_header
                print_info "Aktualisiere alle Repositories..."
                sudo zypper refresh
                check_exit "Repositories erfolgreich aktualisiert" "Fehler beim Aktualisieren"
                read -p "Drücke Enter um fortzufahren..."
                ;;
            2)
                print_header
                print_info "Überprüfe Paketabhängigkeiten..."
                sudo zypper verify
                check_exit "Paketdatenbank ist konsistent" "Probleme gefunden – siehe oben"
                read -p "Drücke Enter um fortzufahren..."
                ;;
            3)
                print_header
                print_warning "Repariere fehlerhafte Abhängigkeiten..."
                sudo zypper install --force-resolution
                check_exit "Abhängigkeiten erfolgreich repariert" "Fehler bei der Reparatur"
                read -p "Drücke Enter um fortzufahren..."
                ;;
            4)
                print_header
                print_info "Suche verwaiste Pakete (ohne aktives Repository)..."
                echo ""
                sudo zypper packages --orphaned
                echo ""
                read -p "Verwaiste Pakete entfernen? (j/N): " confirm
                if [[ $confirm == "j" || $confirm == "J" ]]; then
                    orphans=$(sudo zypper packages --orphaned 2>/dev/null \
                        | awk -F'|' 'NR>4 && $3 ~ /i/ {gsub(/ /,"",$5); print $5}' \
                        | tr '\n' ' ')
                    if [ -n "$orphans" ]; then
                        sudo zypper remove $orphans
                        check_exit "Verwaiste Pakete entfernt" "Fehler beim Entfernen"
                    else
                        print_info "Keine entfernbaren verwaisten Pakete gefunden"
                    fi
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            5)
                print_header
                print_warning "Baue RPM-Datenbank neu auf..."
                sudo rpm --rebuilddb
                check_exit "RPM-Datenbank erfolgreich neu aufgebaut" "Fehler beim Neuaufbau"
                read -p "Drücke Enter um fortzufahren..."
                ;;
            6)
                print_header
                print_info "Leere Zypper-Cache..."
                sudo zypper clean --all
                check_exit "Cache erfolgreich geleert" "Fehler beim Leeren des Cache"
                read -p "Drücke Enter um fortzufahren..."
                ;;
            7)
                print_header
                read -p "Paketname eingeben: " package
                if [ -z "$package" ]; then
                    print_error "Kein Paket eingegeben"
                else
                    print_info "Installiere '$package' neu..."
                    sudo zypper install --force "$package"
                    check_exit "Paket '$package' erfolgreich neu installiert" "Fehler beim Neuinstallieren"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            8)
                print_header
                print_info "Suche doppelt installierte Pakete..."
                sudo zypper packages --duplicates
                echo ""
                read -p "Duplikate automatisch bereinigen? (j/N): " confirm
                if [[ $confirm == "j" || $confirm == "J" ]]; then
                    sudo zypper dup --no-allow-downgrade
                    check_exit "Duplikate bereinigt" "Fehler bei der Bereinigung"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            9)
                print_header
                print_warning "WARNUNG: Vollständige Systemreparatur!"
                print_warning "Mehrere Schritte werden nacheinander ausgeführt."
                read -p "Fortfahren? (j/N): " confirm
                if [[ $confirm == "j" || $confirm == "J" ]]; then
                    print_info "Schritt 1: Baue RPM-Datenbank neu auf..."
                    sudo rpm --rebuilddb

                    print_info "Schritt 2: Leere Zypper-Cache..."
                    sudo zypper clean --all

                    print_info "Schritt 3: Aktualisiere Repositories..."
                    sudo zypper refresh --force

                    print_info "Schritt 4: Überprüfe Paketabhängigkeiten..."
                    sudo zypper verify

                    print_info "Schritt 5: Entferne verwaiste Pakete..."
                    sudo zypper packages --orphaned

                    print_info "Schritt 6: Führe Distributions-Upgrade durch..."
                    sudo zypper dist-upgrade

                    print_success "Vollständige Systemreparatur abgeschlossen"
                else
                    print_info "Abgebrochen"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            10)
                print_header
                print_info "Zypper-Konfiguration (/etc/zypp/zypp.conf):"
                echo ""
                sudo grep -v "^#" /etc/zypp/zypp.conf | grep -v "^$"
                read -p "Drücke Enter um fortzufahren..."
                ;;
            11)
                return
                ;;
            *)
                print_error "Ungültige Option"
                sleep 1
                ;;
        esac
    done
}

# ============================================================
# Repository Menü
# ============================================================
repository_menu() {
    while true; do
        print_header
        echo -e "${MAGENTA}=== REPOSITORY MANAGEMENT ===${NC}"
        echo ""
        echo -e "${GREEN}1)${NC}  Alle Repositories anzeigen"
        echo -e "${GREEN}2)${NC}  Packman Repository hinzufügen (Multimedia)"
        echo -e "${GREEN}3)${NC}  openSUSE OSS Repository hinzufügen"
        echo -e "${GREEN}4)${NC}  openSUSE Non-OSS Repository hinzufügen"
        echo -e "${GREEN}5)${NC}  openSUSE Update Repository hinzufügen"
        echo -e "${GREEN}6)${NC}  Eigenes Repository hinzufügen (URL)"
        echo -e "${GREEN}7)${NC}  Repository entfernen"
        echo -e "${GREEN}8)${NC}  Repository aktivieren"
        echo -e "${GREEN}9)${NC}  Repository deaktivieren"
        echo -e "${GREEN}10)${NC} Repository-Priorität setzen"
        echo -e "${GREEN}11)${NC} Alle Repositories aktualisieren (refresh)"
        echo -e "${GREEN}12)${NC} Packman-Pakete umstellen (vendor switch)"
        echo -e "${GREEN}13)${NC} Zurück zum Hauptmenü"
        echo ""
        read -p "Wähle eine Option [1-13]: " choice

        case $choice in
            1)
                print_header
                print_section "Alle konfigurierten Repositories"
                sudo zypper repos --details
                read -p "Drücke Enter um fortzufahren..."
                ;;
            2)
                print_header
                print_section "Packman Repository (Multimedia)"
                print_info "Packman ist das wichtigste Drittanbieter-Repo für openSUSE"
                print_info "Es enthält: Codecs, VLC, FFmpeg, GStreamer-Plugins..."
                echo ""
                print_info "Erkenne openSUSE-Version..."
                VERSION=$(awk -F= '/^VERSION_ID/{print $2}' /etc/os-release | tr -d '"')

                if echo "$VERSION" | grep -qi "tumbleweed"; then
                    PACKMAN_URL="https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/"
                else
                    PACKMAN_URL="https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Leap_${VERSION}/"
                fi

                print_info "Repository-URL: $PACKMAN_URL"
                echo ""
                read -p "Packman hinzufügen? (j/N): " confirm
                if [[ $confirm == "j" || $confirm == "J" ]]; then
                    sudo zypper addrepo --refresh --priority 90 \
                        "$PACKMAN_URL" packman
                    if [ $? -eq 0 ]; then
                        print_success "Packman Repository erfolgreich hinzugefügt"
                        print_info "Importiere GPG-Schlüssel..."
                        sudo zypper refresh packman
                        echo ""
                        print_warning "Tipp: Wähle Option 12 um auf Packman-Pakete umzustellen"
                    else
                        print_error "Fehler beim Hinzufügen"
                    fi
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            3)
                print_header
                print_section "openSUSE Tumbleweed OSS Repository"
                print_info "Offizielle Open-Source-Pakete"
                sudo zypper addrepo --refresh \
                    "https://download.opensuse.org/tumbleweed/repo/oss/" \
                    "openSUSE-Tumbleweed-Oss"
                check_exit "OSS Repository hinzugefügt" "Fehler oder bereits vorhanden"
                sudo zypper refresh
                read -p "Drücke Enter um fortzufahren..."
                ;;
            4)
                print_header
                print_section "openSUSE Tumbleweed Non-OSS Repository"
                print_info "Nicht-freie Pakete (proprietäre Software)"
                sudo zypper addrepo --refresh \
                    "https://download.opensuse.org/tumbleweed/repo/non-oss/" \
                    "openSUSE-Tumbleweed-Non-Oss"
                check_exit "Non-OSS Repository hinzugefügt" "Fehler oder bereits vorhanden"
                sudo zypper refresh
                read -p "Drücke Enter um fortzufahren..."
                ;;
            5)
                print_header
                print_section "openSUSE Tumbleweed Update Repository"
                print_info "Aktualisierungen und Sicherheitspatches"
                sudo zypper addrepo --refresh \
                    "https://download.opensuse.org/update/tumbleweed/" \
                    "openSUSE-Tumbleweed-Update"
                check_exit "Update Repository hinzugefügt" "Fehler oder bereits vorhanden"
                sudo zypper refresh
                read -p "Drücke Enter um fortzufahren..."
                ;;
            6)
                print_header
                print_section "Eigenes Repository hinzufügen"
                read -p "Repository-URL eingeben: " repo_url
                read -p "Repository-Name/Alias eingeben: " repo_alias
                read -p "Priorität (1-200, Standard 99): " repo_prio
                repo_prio=${repo_prio:-99}

                if [ -z "$repo_url" ] || [ -z "$repo_alias" ]; then
                    print_error "URL und Name dürfen nicht leer sein"
                else
                    sudo zypper addrepo --refresh --priority "$repo_prio" \
                        "$repo_url" "$repo_alias"
                    if [ $? -eq 0 ]; then
                        print_success "Repository '$repo_alias' erfolgreich hinzugefügt"
                        print_info "Aktualisiere Repository..."
                        sudo zypper refresh "$repo_alias"
                    else
                        print_error "Fehler beim Hinzufügen"
                    fi
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            7)
                print_header
                print_section "Repository entfernen"
                print_info "Aktuelle Repositories:"
                sudo zypper repos
                echo ""
                read -p "Repository-Alias oder Nummer eingeben: " repo_id
                if [ -z "$repo_id" ]; then
                    print_error "Keine Eingabe"
                else
                    print_warning "Entferne Repository: $repo_id"
                    sudo zypper removerepo "$repo_id"
                    check_exit "Repository '$repo_id' erfolgreich entfernt" "Fehler beim Entfernen"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            8)
                print_header
                print_section "Repository aktivieren"
                sudo zypper repos
                echo ""
                read -p "Repository-Alias oder Nummer eingeben: " repo_id
                if [ -z "$repo_id" ]; then
                    print_error "Keine Eingabe"
                else
                    sudo zypper modifyrepo --enable "$repo_id"
                    check_exit "Repository '$repo_id' aktiviert" "Fehler beim Aktivieren"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            9)
                print_header
                print_section "Repository deaktivieren"
                sudo zypper repos
                echo ""
                read -p "Repository-Alias oder Nummer eingeben: " repo_id
                if [ -z "$repo_id" ]; then
                    print_error "Keine Eingabe"
                else
                    sudo zypper modifyrepo --disable "$repo_id"
                    check_exit "Repository '$repo_id' deaktiviert" "Fehler beim Deaktivieren"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            10)
                print_header
                print_section "Repository-Priorität setzen"
                print_info "Niedrigere Zahl = höhere Priorität (Standard: 99)"
                print_info "Packman empfohlen: 90 | Eigene Repos: 80-95"
                echo ""
                sudo zypper repos
                echo ""
                read -p "Repository-Alias eingeben: " repo_id
                read -p "Neue Priorität (1-200): " priority
                if [ -z "$repo_id" ] || [ -z "$priority" ]; then
                    print_error "Alias und Priorität sind erforderlich"
                else
                    sudo zypper modifyrepo --priority "$priority" "$repo_id"
                    check_exit "Priorität für '$repo_id' auf $priority gesetzt" "Fehler beim Setzen der Priorität"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            11)
                print_header
                print_info "Aktualisiere alle Repositories..."
                sudo zypper refresh --force
                check_exit "Alle Repositories aktualisiert" "Fehler beim Aktualisieren"
                read -p "Drücke Enter um fortzufahren..."
                ;;
            12)
                print_header
                print_section "Packman Vendor Switch"
                print_warning "Dies stellt alle passenden Pakete auf Packman-Versionen um."
                print_info "Empfohlen nach der Erstinstallation des Packman-Repositories"
                print_info "Betrifft vor allem: VLC, FFmpeg, GStreamer, Codecs"
                echo ""
                read -p "Vendor Switch durchführen? (j/N): " confirm
                if [[ $confirm == "j" || $confirm == "J" ]]; then
                    print_info "Führe Vendor Switch durch..."
                    sudo zypper dist-upgrade --from packman --allow-vendor-change
                    check_exit "Vendor Switch erfolgreich abgeschlossen" "Fehler beim Vendor Switch"
                else
                    print_info "Abgebrochen"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            13)
                return
                ;;
            *)
                print_error "Ungültige Option"
                sleep 1
                ;;
        esac
    done
}

# ============================================================
# Systeminformationen Menü
# ============================================================
sysinfo_menu() {
    while true; do
        print_header
        echo -e "${CYAN}=== SYSTEMINFORMATIONEN ===${NC}"
        echo ""
        echo -e "${GREEN}1)${NC} Betriebssystem & Kernel"
        echo -e "${GREEN}2)${NC} CPU-Informationen"
        echo -e "${GREEN}3)${NC} Arbeitsspeicher (RAM & Swap)"
        echo -e "${GREEN}4)${NC} Festplatten & Partitionen"
        echo -e "${GREEN}5)${NC} Netzwerkinterfaces"
        echo -e "${GREEN}6)${NC} Laufende Dienste (systemd)"
        echo -e "${GREEN}7)${NC} Installierte Pakete zählen"
        echo -e "${GREEN}8)${NC} Systemlast & Uptime"
        echo -e "${GREEN}9)${NC} openSUSE-Snapshot-Verlauf (snapper)"
        echo -e "${GREEN}10)${NC} Zurück zum Hauptmenü"
        echo ""
        read -p "Wähle eine Option [1-10]: " choice

        case $choice in
            1)
                print_header
                print_section "Betriebssystem & Kernel"
                echo -e "${YELLOW}Distribution:${NC}"
                cat /etc/os-release | grep -E "^(NAME|VERSION|PRETTY_NAME)"
                echo ""
                echo -e "${YELLOW}Kernel:${NC}        $(uname -r)"
                echo -e "${YELLOW}Architektur:${NC}   $(uname -m)"
                echo -e "${YELLOW}Hostname:${NC}      $(hostname -f)"
                echo -e "${YELLOW}Boot-Zeit:${NC}     $(who -b | awk '{print $3, $4}')"
                echo ""
                if command -v snapper &>/dev/null; then
                    echo -e "${YELLOW}Aktueller Snapshot:${NC}"
                    sudo snapper list --type=single 2>/dev/null | tail -3
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            2)
                print_header
                print_section "CPU-Informationen"
                lscpu
                echo ""
                echo -e "${YELLOW}Aktuelle CPU-Frequenz:${NC}"
                grep "cpu MHz" /proc/cpuinfo | head -4
                read -p "Drücke Enter um fortzufahren..."
                ;;
            3)
                print_header
                print_section "Arbeitsspeicher"
                free -h
                echo ""
                echo -e "${YELLOW}Details:${NC}"
                cat /proc/meminfo | grep -E "MemTotal|MemFree|MemAvailable|Cached:|SwapTotal|SwapFree|Buffers"
                read -p "Drücke Enter um fortzufahren..."
                ;;
            4)
                print_header
                print_section "Festplatten & Partitionen"
                echo -e "${YELLOW}Blockgeräte:${NC}"
                lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,LABEL
                echo ""
                echo -e "${YELLOW}Festplattennutzung:${NC}"
                df -hT | grep -v tmpfs | grep -v devtmpfs
                echo ""
                if command -v btrfs &>/dev/null; then
                    echo -e "${YELLOW}Btrfs-Subvolumes:${NC}"
                    sudo btrfs subvolume list / 2>/dev/null | head -20
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            5)
                print_header
                print_section "Netzwerkinterfaces"
                ip addr show
                echo ""
                echo -e "${YELLOW}Routing-Tabelle:${NC}"
                ip route show
                echo ""
                echo -e "${YELLOW}DNS-Konfiguration:${NC}"
                cat /etc/resolv.conf | grep -v "^#"
                read -p "Drücke Enter um fortzufahren..."
                ;;
            6)
                print_header
                print_section "Laufende systemd-Dienste"
                systemctl list-units --type=service --state=running --no-pager
                read -p "Drücke Enter um fortzufahren..."
                ;;
            7)
                print_header
                print_section "Installierte Pakete"
                total=$(rpm -qa | wc -l)
                print_info "Gesamtanzahl installierter Pakete: ${WHITE}$total${NC}"
                echo ""
                echo -e "${YELLOW}Zuletzt installierte Pakete (20):${NC}"
                rpm -qa --last | head -20
                echo ""
                echo -e "${YELLOW}Größte Pakete:${NC}"
                rpm -qa --queryformat '%{SIZE} %{NAME}\n' | sort -rn | head -10 | \
                    awk '{printf "%-10s MB  %s\n", int($1/1024/1024), $2}'
                read -p "Drücke Enter um fortzufahren..."
                ;;
            8)
                print_header
                print_section "Systemlast & Uptime"
                echo -e "${YELLOW}Uptime:${NC}  $(uptime -p)"
                echo -e "${YELLOW}Systemlast:${NC}"
                uptime
                echo ""
                echo -e "${YELLOW}Top-Prozesse nach CPU:${NC}"
                ps aux --sort=-%cpu | head -11
                echo ""
                echo -e "${YELLOW}Top-Prozesse nach RAM:${NC}"
                ps aux --sort=-%mem | head -6
                read -p "Drücke Enter um fortzufahren..."
                ;;
            9)
                print_header
                print_section "Snapper – Snapshot-Verlauf"
                if ! command -v snapper &>/dev/null; then
                    print_warning "snapper ist nicht installiert"
                    read -p "snapper jetzt installieren? (j/N): " confirm
                    if [[ $confirm == "j" || $confirm == "J" ]]; then
                        sudo zypper install snapper
                    fi
                else
                    echo -e "${YELLOW}Konfigurationen:${NC}"
                    sudo snapper list-configs
                    echo ""
                    echo -e "${YELLOW}Snapshots:${NC}"
                    sudo snapper list
                    echo ""
                    read -p "Snapshot erstellen? (j/N): " snap_confirm
                    if [[ $snap_confirm == "j" || $snap_confirm == "J" ]]; then
                        read -p "Beschreibung des Snapshots: " snap_desc
                        sudo snapper create --description "${snap_desc:-Manueller Snapshot}"
                        check_exit "Snapshot erstellt" "Fehler beim Erstellen"
                    fi
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            10)
                return
                ;;
            *)
                print_error "Ungültige Option"
                sleep 1
                ;;
        esac
    done
}

# ============================================================
# Dienste-Verwaltung Menü
# ============================================================
services_menu() {
    while true; do
        print_header
        echo -e "${BLUE}=== DIENSTE-VERWALTUNG (SYSTEMD) ===${NC}"
        echo ""
        echo -e "${GREEN}1)${NC}  Dienst starten"
        echo -e "${GREEN}2)${NC}  Dienst stoppen"
        echo -e "${GREEN}3)${NC}  Dienst neu starten"
        echo -e "${GREEN}4)${NC}  Dienst-Status anzeigen"
        echo -e "${GREEN}5)${NC}  Dienst aktivieren (Autostart)"
        echo -e "${GREEN}6)${NC}  Dienst deaktivieren (kein Autostart)"
        echo -e "${GREEN}7)${NC}  Alle aktiven Dienste anzeigen"
        echo -e "${GREEN}8)${NC}  Fehlgeschlagene Dienste anzeigen"
        echo -e "${GREEN}9)${NC}  Journal-Logs anzeigen (journalctl)"
        echo -e "${GREEN}10)${NC} Systemd-Analyse & Boot-Zeiten"
        echo -e "${GREEN}11)${NC} Zurück zum Hauptmenü"
        echo ""
        read -p "Wähle eine Option [1-11]: " choice

        case $choice in
            1)
                print_header
                read -p "Dienstname eingeben (z.B. apache2): " service
                if [ -z "$service" ]; then
                    print_error "Kein Dienstname eingegeben"
                else
                    print_info "Starte Dienst: $service"
                    sudo systemctl start "$service"
                    if [ $? -eq 0 ]; then
                        print_success "Dienst '$service' erfolgreich gestartet"
                        sudo systemctl status "$service" --no-pager -l | head -15
                    else
                        print_error "Fehler beim Starten von '$service'"
                    fi
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            2)
                print_header
                read -p "Dienstname eingeben: " service
                if [ -z "$service" ]; then
                    print_error "Kein Dienstname eingegeben"
                else
                    print_warning "Stoppe Dienst: $service"
                    sudo systemctl stop "$service"
                    check_exit "Dienst '$service' erfolgreich gestoppt" "Fehler beim Stoppen"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            3)
                print_header
                read -p "Dienstname eingeben: " service
                if [ -z "$service" ]; then
                    print_error "Kein Dienstname eingegeben"
                else
                    print_info "Starte Dienst neu: $service"
                    sudo systemctl restart "$service"
                    if [ $? -eq 0 ]; then
                        print_success "Dienst '$service' erfolgreich neu gestartet"
                        sudo systemctl status "$service" --no-pager -l | head -15
                    else
                        print_error "Fehler beim Neustart von '$service'"
                    fi
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            4)
                print_header
                read -p "Dienstname eingeben: " service
                if [ -z "$service" ]; then
                    print_error "Kein Dienstname eingegeben"
                else
                    echo ""
                    sudo systemctl status "$service" --no-pager -l
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            5)
                print_header
                read -p "Dienstname eingeben: " service
                if [ -z "$service" ]; then
                    print_error "Kein Dienstname eingegeben"
                else
                    print_info "Aktiviere Autostart für: $service"
                    sudo systemctl enable "$service"
                    check_exit "Dienst '$service' aktiviert (startet automatisch)" "Fehler beim Aktivieren"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            6)
                print_header
                read -p "Dienstname eingeben: " service
                if [ -z "$service" ]; then
                    print_error "Kein Dienstname eingegeben"
                else
                    print_warning "Deaktiviere Autostart für: $service"
                    sudo systemctl disable "$service"
                    check_exit "Autostart für '$service' deaktiviert" "Fehler beim Deaktivieren"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            7)
                print_header
                print_section "Aktive Dienste"
                systemctl list-units --type=service --state=running --no-pager
                read -p "Drücke Enter um fortzufahren..."
                ;;
            8)
                print_header
                print_section "Fehlgeschlagene Dienste"
                failed=$(systemctl list-units --type=service --state=failed --no-pager 2>&1)
                if echo "$failed" | grep -q "0 loaded units listed"; then
                    print_success "Keine fehlgeschlagenen Dienste gefunden"
                else
                    echo "$failed"
                    echo ""
                    read -p "Journal-Log eines Dienstes anzeigen? (j/N): " show_log
                    if [[ $show_log == "j" || $show_log == "J" ]]; then
                        read -p "Dienstname eingeben: " service
                        sudo journalctl -u "$service" --no-pager -n 50
                    fi
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            9)
                print_header
                print_section "Journal-Logs (journalctl)"
                echo -e "${GREEN}1)${NC} Gesamtes Journal (letzte 50 Einträge)"
                echo -e "${GREEN}2)${NC} Journal eines bestimmten Dienstes"
                echo -e "${GREEN}3)${NC} Kernel-Logs"
                echo -e "${GREEN}4)${NC} Logs seit letztem Boot"
                echo -e "${GREEN}5)${NC} Fehler-Logs (priority: err)"
                echo ""
                read -p "Option wählen [1-5]: " log_choice
                case $log_choice in
                    1) sudo journalctl --no-pager -n 50 ;;
                    2)
                        read -p "Dienstname: " svc
                        sudo journalctl -u "$svc" --no-pager -n 50
                        ;;
                    3) sudo journalctl -k --no-pager -n 50 ;;
                    4) sudo journalctl -b --no-pager -n 50 ;;
                    5) sudo journalctl -p err --no-pager -n 50 ;;
                    *) print_error "Ungültige Option" ;;
                esac
                read -p "Drücke Enter um fortzufahren..."
                ;;
            10)
                print_header
                print_section "Systemd Boot-Analyse"
                echo -e "${YELLOW}Boot-Zeiten:${NC}"
                systemd-analyze
                echo ""
                echo -e "${YELLOW}Top 10 langsamste Dienste beim Boot:${NC}"
                systemd-analyze blame | head -10
                echo ""
                echo -e "${YELLOW}Kritischer Boot-Pfad:${NC}"
                systemd-analyze critical-chain 2>/dev/null | head -20
                read -p "Drücke Enter um fortzufahren..."
                ;;
            11)
                return
                ;;
            *)
                print_error "Ungültige Option"
                sleep 1
                ;;
        esac
    done
}

# ============================================================
# YaST / System-Extras Menü  ← openSUSE-spezifisch
# ============================================================
yast_extras_menu() {
    while true; do
        print_header
        echo -e "${GREEN}=== OPENSUSE SYSTEM-EXTRAS ===${NC}"
        echo ""
        echo -e "${GREEN}1)${NC}  YaST2 (grafisch) starten"
        echo -e "${GREEN}2)${NC}  YaST2 ncurses (Terminal) starten"
        echo -e "${GREEN}3)${NC}  Firewall-Status (firewalld)"
        echo -e "${GREEN}4)${NC}  Firewall-Dienst öffnen/schließen"
        echo -e "${GREEN}5)${NC}  AppArmor-Status anzeigen"
        echo -e "${GREEN}6)${NC}  Btrfs-Snapshots verwalten (snapper)"
        echo -e "${GREEN}7)${NC}  Transaktions-Update (read-only root)"
        echo -e "${GREEN}8)${NC}  Flatpak einrichten & verwalten"
        echo -e "${GREEN}9)${NC}  Zurück zum Hauptmenü"
        echo ""
        read -p "Wähle eine Option [1-9]: " choice

        case $choice in
            1)
                print_header
                if command -v yast2 &>/dev/null; then
                    print_info "Starte YaST2 (grafisch)..."
                    sudo yast2 &
                    print_success "YaST2 wurde gestartet"
                else
                    print_error "YaST2 ist nicht installiert"
                    read -p "Installieren? (j/N): " confirm
                    [[ $confirm == "j" || $confirm == "J" ]] && sudo zypper install yast2
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            2)
                print_header
                if command -v yast2 &>/dev/null; then
                    print_info "Starte YaST2 (ncurses)..."
                    sudo yast2
                else
                    print_error "YaST2 ist nicht installiert"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            3)
                print_header
                print_section "Firewall-Status (firewalld)"
                sudo systemctl status firewalld --no-pager | head -20
                echo ""
                echo -e "${YELLOW}Aktive Zone:${NC}"
                sudo firewall-cmd --get-active-zones 2>/dev/null || print_warning "firewalld nicht aktiv"
                echo ""
                echo -e "${YELLOW}Erlaubte Dienste:${NC}"
                sudo firewall-cmd --list-services 2>/dev/null
                read -p "Drücke Enter um fortzufahren..."
                ;;
            4)
                print_header
                print_section "Firewall-Dienst hinzufügen/entfernen"
                echo -e "${YELLOW}Verfügbare Dienste:${NC}"
                sudo firewall-cmd --get-services 2>/dev/null | tr ' ' '\n' | column
                echo ""
                read -p "Dienstname eingeben (z.B. ssh, http, https): " fw_service
                if [ -z "$fw_service" ]; then
                    print_error "Keine Eingabe"
                else
                    echo ""
                    echo -e "${GREEN}1)${NC} Dienst dauerhaft hinzufügen"
                    echo -e "${GREEN}2)${NC} Dienst dauerhaft entfernen"
                    read -p "Option [1-2]: " fw_action
                    case $fw_action in
                        1)
                            sudo firewall-cmd --permanent --add-service="$fw_service"
                            sudo firewall-cmd --reload
                            check_exit "Dienst '$fw_service' zur Firewall hinzugefügt" "Fehler"
                            ;;
                        2)
                            sudo firewall-cmd --permanent --remove-service="$fw_service"
                            sudo firewall-cmd --reload
                            check_exit "Dienst '$fw_service' aus Firewall entfernt" "Fehler"
                            ;;
                        *)
                            print_error "Ungültige Option" ;;
                    esac
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            5)
                print_header
                print_section "AppArmor"
                if command -v aa-status &>/dev/null; then
                    sudo aa-status
                else
                    print_warning "AppArmor-Tools nicht installiert"
                    read -p "apparmor-utils installieren? (j/N): " confirm
                    [[ $confirm == "j" || $confirm == "J" ]] && sudo zypper install apparmor-utils
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            6)
                print_header
                print_section "Snapper – Btrfs-Snapshots"
                if ! command -v snapper &>/dev/null; then
                    print_warning "snapper nicht installiert"
                    read -p "Installieren? (j/N): " confirm
                    [[ $confirm == "j" || $confirm == "J" ]] && sudo zypper install snapper
                else
                    echo -e "${GREEN}1)${NC} Alle Snapshots anzeigen"
                    echo -e "${GREEN}2)${NC} Snapshot erstellen"
                    echo -e "${GREEN}3)${NC} Snapshot löschen"
                    echo -e "${GREEN}4)${NC} Zwei Snapshots vergleichen (diff)"
                    echo ""
                    read -p "Option [1-4]: " snap_opt
                    case $snap_opt in
                        1)
                            sudo snapper list
                            ;;
                        2)
                            read -p "Beschreibung: " snap_desc
                            sudo snapper create --description "${snap_desc:-Manuell}"
                            check_exit "Snapshot erstellt" "Fehler"
                            ;;
                        3)
                            sudo snapper list
                            echo ""
                            read -p "Snapshot-Nummer eingeben: " snap_nr
                            sudo snapper delete "$snap_nr"
                            check_exit "Snapshot $snap_nr gelöscht" "Fehler"
                            ;;
                        4)
                            sudo snapper list
                            echo ""
                            read -p "Erste Snapshot-Nr: " snap1
                            read -p "Zweite Snapshot-Nr: " snap2
                            sudo snapper diff "$snap1" "$snap2"
                            ;;
                        *)
                            print_error "Ungültige Option" ;;
                    esac
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            7)
                print_header
                print_section "Transaktions-Update (transactional-update)"
                if ! command -v transactional-update &>/dev/null; then
                    print_warning "transactional-update ist auf diesem System nicht aktiv"
                    print_info "Wird nur bei MicroOS / read-only Root-Systemen eingesetzt"
                else
                    echo -e "${GREEN}1)${NC} System aktualisieren (transactional-update dup)"
                    echo -e "${GREEN}2)${NC} Paket installieren"
                    echo -e "${GREEN}3)${NC} Snapper-Rollback"
                    echo ""
                    read -p "Option [1-3]: " tu_opt
                    case $tu_opt in
                        1)
                            sudo transactional-update dup
                            check_exit "Update erfolgreich – Neustart erforderlich" "Fehler"
                            ;;
                        2)
                            read -p "Paketname: " pkg
                            sudo transactional-update pkg install "$pkg"
                            check_exit "Paket installiert – Neustart erforderlich" "Fehler"
                            ;;
                        3)
                            sudo snapper rollback
                            print_warning "Bitte System neu starten, um Rollback abzuschließen"
                            ;;
                        *)
                            print_error "Ungültige Option" ;;
                    esac
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            8)
                print_header
                print_section "Flatpak"
                if ! command -v flatpak &>/dev/null; then
                    print_warning "Flatpak ist nicht installiert"
                    read -p "Flatpak installieren? (j/N): " confirm
                    if [[ $confirm == "j" || $confirm == "J" ]]; then
                        sudo zypper install flatpak
                        sudo flatpak remote-add --if-not-exists flathub \
                            https://dl.flathub.org/repo/flathub.flatpakrepo
                        print_success "Flatpak + Flathub eingerichtet"
                        print_warning "Bitte neu einloggen, damit Flatpak-Apps im Menü erscheinen"
                    fi
                else
                    echo -e "${GREEN}1)${NC} Installierte Apps anzeigen"
                    echo -e "${GREEN}2)${NC} App installieren (Flathub)"
                    echo -e "${GREEN}3)${NC} App deinstallieren"
                    echo -e "${GREEN}4)${NC} Alle Flatpak-Apps aktualisieren"
                    echo -e "${GREEN}5)${NC} Nicht verwendete Daten bereinigen"
                    echo ""
                    read -p "Option [1-5]: " flat_opt
                    case $flat_opt in
                        1) flatpak list ;;
                        2)
                            read -p "App-ID (z.B. org.videolan.VLC): " app_id
                            flatpak install flathub "$app_id"
                            ;;
                        3)
                            read -p "App-ID eingeben: " app_id
                            flatpak uninstall "$app_id"
                            ;;
                        4)
                            flatpak update
                            check_exit "Alle Apps aktualisiert" "Fehler beim Update"
                            ;;
                        5)
                            flatpak uninstall --unused
                            check_exit "Bereinigung abgeschlossen" "Fehler"
                            ;;
                        *)
                            print_error "Ungültige Option" ;;
                    esac
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            9)
                return
                ;;
            *)
                print_error "Ungültige Option"
                sleep 1
                ;;
        esac
    done
}

# ============================================================
# Hauptmenü
# ============================================================
main_menu() {
    while true; do
        print_header
        echo -e "${WHITE}=== HAUPTMENÜ ===${NC}"
        echo ""
        echo -e "${GREEN}1)${NC}  📦 Zypper Paketmanager"
        echo -e "${GREEN}2)${NC}  🗄️  Repository-Verwaltung"
        echo -e "${GREEN}3)${NC}  ℹ️  Systeminformationen"
        echo -e "${GREEN}4)${NC}  ⚙️  Dienste-Verwaltung (systemd)"
        echo -e "${GREEN}5)${NC}  🦎 openSUSE-Extras (YaST, Snapper, Flatpak)"
        echo -e "${GREEN}6)${NC}  🚪 Beenden"
        echo ""
        read -p "Wähle eine Option [1-6]: " choice

        case $choice in
            1) zypper_menu ;;
            2) repository_menu ;;
            3) sysinfo_menu ;;
            4) services_menu ;;
            5) yast_extras_menu ;;
            6)
                print_header
                echo -e "${CYAN}Auf Wiedersehen! Tschüss! 🦎${NC}"
                echo ""
                exit 0
                ;;
            *)
                print_error "Ungültige Option"
                sleep 1
                ;;
        esac
    done
}

# ============================================================
# Einstiegspunkt
# ============================================================

# Prüfe ob zypper vorhanden ist
if ! command -v zypper &>/dev/null; then
    echo -e "${RED}✗ Fehler: zypper nicht gefunden.${NC}"
    echo -e "${YELLOW}  Dieses Skript erfordert openSUSE / SUSE Linux.${NC}"
    exit 1
fi

# Root-Hinweis
if [ "$EUID" -eq 0 ]; then
    echo -e "${YELLOW}⚠ Hinweis: Skript läuft als root. sudo-Befehle werden direkt ausgeführt.${NC}"
    sleep 1
fi

main_menu
