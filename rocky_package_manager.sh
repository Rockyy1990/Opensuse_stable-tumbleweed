#!/bin/bash

# Farben definieren
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Funktionen für Ausgabe
print_header() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}      Rocky Linux Package Manager${CYAN}      ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
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

# ============================================================
# DNF Menü
# ============================================================
dnf_menu() {
    while true; do
        print_header
        echo -e "${YELLOW}=== DNF PAKETMANAGER MENÜ ===${NC}"
        echo ""
        echo -e "${GREEN}1)${NC} Paketlisten aktualisieren (dnf check-update)"
        echo -e "${GREEN}2)${NC} Pakete installieren"
        echo -e "${GREEN}3)${NC} Pakete entfernen"
        echo -e "${GREEN}4)${NC} Nach Paketen suchen"
        echo -e "${GREEN}5)${NC} Paketinformationen anzeigen"
        echo -e "${GREEN}6)${NC} Systemupgrade (dnf upgrade)"
        echo -e "${GREEN}7)${NC} Cache leeren (dnf clean all)"
        echo -e "${GREEN}8)${NC} DNF Reparatur & Wartung"
        echo -e "${GREEN}9)${NC} Zurück zum Hauptmenü"
        echo ""
        read -p "Wähle eine Option [1-9]: " choice

        case $choice in
            1)
                print_header
                print_info "Überprüfe verfügbare Updates..."
                sudo dnf check-update
                if [ $? -eq 0 ]; then
                    print_success "Paketlisten erfolgreich überprüft"
                else
                    print_info "Überprüfung abgeschlossen"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            2)
                print_header
                read -p "Paketname eingeben (durch Leerzeichen trennen): " packages
                if [ -z "$packages" ]; then
                    print_error "Keine Pakete eingegeben"
                else
                    print_info "Installiere Pakete: $packages"
                    sudo dnf install $packages
                    if [ $? -eq 0 ]; then
                        print_success "Pakete erfolgreich installiert"
                    else
                        print_error "Fehler beim Installieren"
                    fi
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            3)
                print_header
                read -p "Paketname eingeben (durch Leerzeichen trennen): " packages
                if [ -z "$packages" ]; then
                    print_error "Keine Pakete eingegeben"
                else
                    print_warning "Entferne Pakete: $packages"
                    sudo dnf remove $packages
                    if [ $? -eq 0 ]; then
                        print_success "Pakete erfolgreich entfernt"
                    else
                        print_error "Fehler beim Entfernen"
                    fi
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            4)
                print_header
                read -p "Suchbegriff eingeben: " search_term
                if [ -z "$search_term" ]; then
                    print_error "Kein Suchbegriff eingegeben"
                else
                    print_info "Suche nach: $search_term"
                    dnf search $search_term
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            5)
                print_header
                read -p "Paketname eingeben: " package
                if [ -z "$package" ]; then
                    print_error "Kein Paket eingegeben"
                else
                    print_info "Zeige Informationen für: $package"
                    dnf info $package
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            6)
                print_header
                print_info "Führe Systemupgrade durch (dnf upgrade)..."
                sudo dnf upgrade
                if [ $? -eq 0 ]; then
                    print_success "Systemupgrade erfolgreich abgeschlossen"
                else
                    print_error "Fehler beim Systemupgrade"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            7)
                print_header
                print_info "Leere DNF-Cache..."
                sudo dnf clean all
                if [ $? -eq 0 ]; then
                    print_success "DNF-Cache erfolgreich geleert"
                else
                    print_error "Fehler beim Leeren des Cache"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            8)
                dnf_repair_menu
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
# DNF Reparatur Menü
# ============================================================
dnf_repair_menu() {
    while true; do
        print_header
        echo -e "${RED}=== DNF REPARATUR & WARTUNG ===${NC}"
        echo ""
        echo -e "${GREEN}1)${NC} Abhängigkeiten reparieren (dnf install --best --allowerasing)"
        echo -e "${GREEN}2)${NC} Verwaiste Pakete entfernen (dnf autoremove)"
        echo -e "${GREEN}3)${NC} Paketdatenbank überprüfen und reparieren"
        echo -e "${GREEN}4)${NC} Cache komplett leeren und neu aufbauen"
        echo -e "${GREEN}5)${NC} Beschädigte RPM-Pakete reparieren"
        echo -e "${GREEN}6)${NC} Systemintegrität überprüfen"
        echo -e "${GREEN}7)${NC} Vollständige Systemreparatur"
        echo -e "${GREEN}8)${NC} DNF-Konfiguration überprüfen"
        echo -e "${GREEN}9)${NC} Zurück zum DNF-Menü"
        echo ""
        read -p "Wähle eine Option [1-9]: " choice

        case $choice in
            1)
                print_header
                print_warning "Repariere fehlerhafte Abhängigkeiten..."
                sudo dnf install --best --allowerasing
                if [ $? -eq 0 ]; then
                    print_success "Abhängigkeiten erfolgreich repariert"
                else
                    print_error "Fehler bei der Reparatur"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            2)
                print_header
                print_info "Suche verwaiste Pakete..."
                orphaned=$(sudo dnf autoremove --dry-run 2>/dev/null | grep "Removing")

                if [ -z "$orphaned" ]; then
                    print_success "Keine verwaisten Pakete gefunden"
                else
                    echo -e "${YELLOW}Verwaiste Pakete gefunden:${NC}"
                    sudo dnf autoremove --dry-run
                    echo ""
                    read -p "Entfernen? (j/N): " confirm

                    if [[ $confirm == "j" || $confirm == "J" ]]; then
                        sudo dnf autoremove
                        if [ $? -eq 0 ]; then
                            print_success "Verwaiste Pakete entfernt"
                        else
                            print_error "Fehler beim Entfernen"
                        fi
                    fi
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            3)
                print_header
                print_info "Überprüfe Paketdatenbank..."
                sudo dnf check
                if [ $? -eq 0 ]; then
                    print_success "Paketdatenbank ist OK"
                else
                    print_warning "Probleme gefunden - versuche zu reparieren..."
                    sudo dnf distro-sync
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            4)
                print_header
                print_warning "WARNUNG: Dies wird den kompletten DNF-Cache leeren!"
                print_warning "Dies kann einige Zeit dauern"
                read -p "Fortfahren? (j/N): " confirm

                if [[ $confirm == "j" || $confirm == "J" ]]; then
                    print_info "Leere Cache..."
                    sudo dnf clean all

                    print_info "Baue Metadaten neu auf..."
                    sudo dnf makecache

                    if [ $? -eq 0 ]; then
                        print_success "Cache erfolgreich neu aufgebaut"
                    else
                        print_error "Fehler beim Neuaufbau"
                    fi
                else
                    print_info "Abgebrochen"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            5)
                print_header
                print_warning "Repariere beschädigte RPM-Pakete..."
                sudo rpm --rebuilddb
                if [ $? -eq 0 ]; then
                    print_success "RPM-Datenbank erfolgreich neu aufgebaut"
                    print_info "Führe DNF-Überprüfung durch..."
                    sudo dnf check
                else
                    print_error "Fehler bei der Reparatur"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            6)
                print_header
                print_info "Überprüfe Systemintegrität..."
                sudo dnf check
                if [ $? -eq 0 ]; then
                    print_success "Systemintegrität ist OK"
                else
                    print_warning "Einige Probleme gefunden - siehe oben"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            7)
                print_header
                print_warning "WARNUNG: Vollständige Systemreparatur wird durchgeführt!"
                print_warning "Dies führt mehrere Reparaturschritte nacheinander aus."
                read -p "Fortfahren? (j/N): " confirm

                if [[ $confirm == "j" || $confirm == "J" ]]; then
                    print_info "Schritt 1: Überprüfe Paketdatenbank..."
                    sudo dnf check

                    print_info "Schritt 2: Synchronisiere Pakete..."
                    sudo dnf distro-sync

                    print_info "Schritt 3: Baue RPM-Datenbank neu auf..."
                    sudo rpm --rebuilddb

                    print_info "Schritt 4: Leere und baue Cache neu auf..."
                    sudo dnf clean all
                    sudo dnf makecache

                    print_info "Schritt 5: Entferne verwaiste Pakete..."
                    sudo dnf autoremove

                    print_success "Vollständige Systemreparatur abgeschlossen"
                else
                    print_info "Abgebrochen"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            8)
                print_header
                print_info "Zeige DNF-Konfiguration..."
                echo ""
                sudo cat /etc/dnf/dnf.conf | grep -v "^#" | grep -v "^$"
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
# Repository Menü  ← VERVOLLSTÄNDIGT ab Option 4
# ============================================================
repository_menu() {
    while true; do
        print_header
        echo -e "${MAGENTA}=== REPOSITORY MANAGEMENT ===${NC}"
        echo ""
        echo -e "${GREEN}1)${NC}  EPEL Repository installieren"
        echo -e "${GREEN}2)${NC}  PowerTools/CRB Repository aktivieren"
        echo -e "${GREEN}3)${NC}  RPM Fusion Repository installieren"
        echo -e "${GREEN}4)${NC}  ELRepo Repository installieren"
        echo -e "${GREEN}5)${NC}  Remi Repository installieren"
        echo -e "${GREEN}6)${NC}  Alle aktivierten Repositories anzeigen"
        echo -e "${GREEN}7)${NC}  Repository deaktivieren"
        echo -e "${GREEN}8)${NC}  Repository aktivieren"
        echo -e "${GREEN}9)${NC}  Repository-Informationen anzeigen"
        echo -e "${GREEN}10)${NC} Zurück zum Hauptmenü"
        echo ""
        read -p "Wähle eine Option [1-10]: " choice

        case $choice in
            1)
                print_header
                print_info "Installiere EPEL Repository..."
                print_info "EPEL (Extra Packages for Enterprise Linux) bietet zusätzliche Pakete"
                sudo dnf install epel-release
                if [ $? -eq 0 ]; then
                    print_success "EPEL Repository erfolgreich installiert"
                    print_info "Aktualisiere Metadaten..."
                    sudo dnf makecache
                else
                    print_error "Fehler beim Installieren"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            2)
                print_header
                print_info "Aktiviere PowerTools/CRB Repository..."
                print_info "Dieses Repository enthält Entwicklungs- und Debug-Pakete"

                if grep -q "Rocky Linux 8" /etc/os-release; then
                    sudo dnf config-manager --set-enabled powertools
                elif grep -q "Rocky Linux 9" /etc/os-release; then
                    sudo dnf config-manager --set-enabled crb
                else
                    print_warning "Unbekannte Rocky Linux Version - versuche CRB..."
                    sudo dnf config-manager --set-enabled crb
                fi

                if [ $? -eq 0 ]; then
                    print_success "Repository erfolgreich aktiviert"
                    sudo dnf makecache
                else
                    print_error "Fehler beim Aktivieren"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            3)
                print_header
                print_info "Installiere RPM Fusion Repository..."
                print_info "RPM Fusion bietet Multimedia und proprietäre Pakete"
                sudo dnf install \
                    https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm \
                    https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm
                if [ $? -eq 0 ]; then
                    print_success "RPM Fusion Repository erfolgreich installiert"
                    print_info "Aktualisiere Metadaten..."
                    sudo dnf makecache
                else
                    print_error "Fehler beim Installieren"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            4)
                print_header
                print_info "Installiere ELRepo Repository..."
                print_info "ELRepo bietet Hardware-Treiber und Kernel-Updates"
                sudo dnf install elrepo-release
                if [ $? -eq 0 ]; then
                    print_success "ELRepo Repository erfolgreich installiert"
                    print_info "Aktualisiere Metadaten..."
                    sudo dnf makecache
                else
                    print_error "Fehler beim Installieren"
                    print_info "Versuche manuelle Installation..."
                    sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
                    sudo dnf install https://www.elrepo.org/elrepo-release-$(rpm -E %rhel).el$(rpm -E %rhel).elrepo.noarch.rpm
                    if [ $? -eq 0 ]; then
                        print_success "ELRepo manuell installiert"
                        sudo dnf makecache
                    else
                        print_error "ELRepo konnte nicht installiert werden"
                    fi
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            5)
                print_header
                print_info "Installiere Remi Repository..."
                print_info "Remi bietet aktuelle PHP- und Datenbankversionen"

                RHEL_VERSION=$(rpm -E %rhel)
                print_info "Erkannte RHEL-Version: $RHEL_VERSION"

                sudo dnf install "https://rpms.remirepo.net/enterprise/remi-release-${RHEL_VERSION}.rpm"
                if [ $? -eq 0 ]; then
                    print_success "Remi Repository erfolgreich installiert"
                    print_info "Aktualisiere Metadaten..."
                    sudo dnf makecache
                    echo ""
                    print_info "Verfügbare PHP-Module (via Remi):"
                    dnf module list php 2>/dev/null | head -20
                else
                    print_error "Fehler beim Installieren des Remi Repositories"
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            6)
                print_header
                echo -e "${MAGENTA}=== AKTIVIERTE REPOSITORIES ===${NC}"
                echo ""
                sudo dnf repolist enabled
                echo ""
                print_info "Gesamte Repo-Liste (auch deaktivierte):"
                sudo dnf repolist all
                read -p "Drücke Enter um fortzufahren..."
                ;;
            7)
                print_header
                print_info "Verfügbare Repositories:"
                sudo dnf repolist all | awk '{print NR")", $1, $2}' | head -30
                echo ""
                read -p "Repository-ID eingeben (z.B. epel): " repo_id
                if [ -z "$repo_id" ]; then
                    print_error "Keine Repository-ID eingegeben"
                else
                    print_warning "Deaktiviere Repository: $repo_id"
                    sudo dnf config-manager --set-disabled "$repo_id"
                    if [ $? -eq 0 ]; then
                        print_success "Repository '$repo_id' erfolgreich deaktiviert"
                    else
                        print_error "Fehler beim Deaktivieren von '$repo_id'"
                    fi
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            8)
                print_header
                print_info "Deaktivierte Repositories:"
                sudo dnf repolist disabled | awk '{print NR")", $1, $2}' | head -30
                echo ""
                read -p "Repository-ID eingeben (z.B. epel): " repo_id
                if [ -z "$repo_id" ]; then
                    print_error "Keine Repository-ID eingegeben"
                else
                    print_info "Aktiviere Repository: $repo_id"
                    sudo dnf config-manager --set-enabled "$repo_id"
                    if [ $? -eq 0 ]; then
                        print_success "Repository '$repo_id' erfolgreich aktiviert"
                        sudo dnf makecache
                    else
                        print_error "Fehler beim Aktivieren von '$repo_id'"
                    fi
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            9)
                print_header
                read -p "Repository-ID eingeben: " repo_id
                if [ -z "$repo_id" ]; then
                    print_error "Keine Repository-ID eingegeben"
                else
                    print_info "Informationen für Repository: $repo_id"
                    echo ""
                    sudo dnf repoinfo "$repo_id"
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
# Systeminformationen Menü  ← NEU
# ============================================================
sysinfo_menu() {
    while true; do
        print_header
        echo -e "${CYAN}=== SYSTEMINFORMATIONEN ===${NC}"
        echo ""
        echo -e "${GREEN}1)${NC} Betriebssystem & Kernel"
        echo -e "${GREEN}2)${NC} CPU-Informationen"
        echo -e "${GREEN}3)${NC} Arbeitsspeicher (RAM)"
        echo -e "${GREEN}4)${NC} Festplatten & Partitionen"
        echo -e "${GREEN}5)${NC} Netzwerkinterfaces"
        echo -e "${GREEN}6)${NC} Laufende Dienste (systemd)"
        echo -e "${GREEN}7)${NC} Installierte Pakete zählen"
        echo -e "${GREEN}8)${NC} Systemlast & Uptime"
        echo -e "${GREEN}9)${NC} Zurück zum Hauptmenü"
        echo ""
        read -p "Wähle eine Option [1-9]: " choice

        case $choice in
            1)
                print_header
                echo -e "${CYAN}=== BETRIEBSSYSTEM & KERNEL ===${NC}"
                echo ""
                cat /etc/os-release
                echo ""
                echo -e "${YELLOW}Kernel:${NC} $(uname -r)"
                echo -e "${YELLOW}Architektur:${NC} $(uname -m)"
                echo -e "${YELLOW}Hostname:${NC} $(hostname -f)"
                read -p "Drücke Enter um fortzufahren..."
                ;;
            2)
                print_header
                echo -e "${CYAN}=== CPU-INFORMATIONEN ===${NC}"
                echo ""
                lscpu
                read -p "Drücke Enter um fortzufahren..."
                ;;
            3)
                print_header
                echo -e "${CYAN}=== ARBEITSSPEICHER ===${NC}"
                echo ""
                free -h
                echo ""
                echo -e "${YELLOW}Details:${NC}"
                cat /proc/meminfo | grep -E "MemTotal|MemFree|MemAvailable|SwapTotal|SwapFree"
                read -p "Drücke Enter um fortzufahren..."
                ;;
            4)
                print_header
                echo -e "${CYAN}=== FESTPLATTEN & PARTITIONEN ===${NC}"
                echo ""
                echo -e "${YELLOW}Partitionen:${NC}"
                lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
                echo ""
                echo -e "${YELLOW}Festplattennutzung:${NC}"
                df -hT | grep -v tmpfs
                read -p "Drücke Enter um fortzufahren..."
                ;;
            5)
                print_header
                echo -e "${CYAN}=== NETZWERKINTERFACES ===${NC}"
                echo ""
                ip addr show
                echo ""
                echo -e "${YELLOW}Routing-Tabelle:${NC}"
                ip route show
                read -p "Drücke Enter um fortzufahren..."
                ;;
            6)
                print_header
                echo -e "${CYAN}=== LAUFENDE DIENSTE ===${NC}"
                echo ""
                systemctl list-units --type=service --state=running --no-pager
                read -p "Drücke Enter um fortzufahren..."
                ;;
            7)
                print_header
                echo -e "${CYAN}=== INSTALLIERTE PAKETE ===${NC}"
                echo ""
                count=$(rpm -qa | wc -l)
                print_info "Anzahl installierter Pakete: ${WHITE}$count${NC}"
                echo ""
                read -p "Die 20 zuletzt installierten Pakete anzeigen? (j/N): " show_recent
                if [[ $show_recent == "j" || $show_recent == "J" ]]; then
                    rpm -qa --last | head -20
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            8)
                print_header
                echo -e "${CYAN}=== SYSTEMLAST & UPTIME ===${NC}"
                echo ""
                echo -e "${YELLOW}Uptime:${NC}"
                uptime -p
                echo ""
                echo -e "${YELLOW}Systemlast:${NC}"
                uptime
                echo ""
                echo -e "${YELLOW}Top-Prozesse (CPU):${NC}"
                ps aux --sort=-%cpu | head -10
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
# Dienste-Verwaltung Menü  ← NEU
# ============================================================
services_menu() {
    while true; do
        print_header
        echo -e "${BLUE}=== DIENSTE-VERWALTUNG (SYSTEMD) ===${NC}"
        echo ""
        echo -e "${GREEN}1)${NC} Dienst starten"
        echo -e "${GREEN}2)${NC} Dienst stoppen"
        echo -e "${GREEN}3)${NC} Dienst neu starten"
        echo -e "${GREEN}4)${NC} Dienst-Status anzeigen"
        echo -e "${GREEN}5)${NC} Dienst aktivieren (Autostart)"
        echo -e "${GREEN}6)${NC} Dienst deaktivieren (kein Autostart)"
        echo -e "${GREEN}7)${NC} Alle aktiven Dienste anzeigen"
        echo -e "${GREEN}8)${NC} Fehlgeschlagene Dienste anzeigen"
        echo -e "${GREEN}9)${NC} Zurück zum Hauptmenü"
        echo ""
        read -p "Wähle eine Option [1-9]: " choice

        case $choice in
            1)
                print_header
                read -p "Dienstname eingeben (z.B. httpd): " service
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
                    if [ $? -eq 0 ]; then
                        print_success "Dienst '$service' erfolgreich gestoppt"
                    else
                        print_error "Fehler beim Stoppen von '$service'"
                    fi
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
                    if [ $? -eq 0 ]; then
                        print_success "Dienst '$service' wird beim Systemstart automatisch gestartet"
                    else
                        print_error "Fehler beim Aktivieren von '$service'"
                    fi
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
                    if [ $? -eq 0 ]; then
                        print_success "Autostart für '$service' deaktiviert"
                    else
                        print_error "Fehler beim Deaktivieren von '$service'"
                    fi
                fi
                read -p "Drücke Enter um fortzufahren..."
                ;;
            7)
                print_header
                echo -e "${CYAN}=== AKTIVE DIENSTE ===${NC}"
                echo ""
                systemctl list-units --type=service --state=running --no-pager
                read -p "Drücke Enter um fortzufahren..."
                ;;
            8)
                print_header
                echo -e "${RED}=== FEHLGESCHLAGENE DIENSTE ===${NC}"
                echo ""
                failed=$(systemctl list-units --type=service --state=failed --no-pager)
                if echo "$failed" | grep -q "0 loaded units listed"; then
                    print_success "Keine fehlgeschlagenen Dienste gefunden"
                else
                    echo "$failed"
                    echo ""
                    read -p "Journal-Logs eines Dienstes anzeigen? (j/N): " show_log
                    if [[ $show_log == "j" || $show_log == "J" ]]; then
                        read -p "Dienstname eingeben: " service
                        sudo journalctl -u "$service" --no-pager -n 30
                    fi
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
        echo -e "${GREEN}1)${NC} 📦 DNF Paketmanager"
        echo -e "${GREEN}2)${NC} 🗄️  Repository-Verwaltung"
        echo -e "${GREEN}3)${NC} ℹ️  Systeminformationen"
        echo -e "${GREEN}4)${NC} ⚙️  Dienste-Verwaltung"
        echo -e "${GREEN}5)${NC} 🚪 Beenden"
        echo ""
        read -p "Wähle eine Option [1-5]: " choice

        case $choice in
            1)
                dnf_menu
                ;;
            2)
                repository_menu
                ;;
            3)
                sysinfo_menu
                ;;
            4)
                services_menu
                ;;
            5)
                print_header
                echo -e "${CYAN}Auf Wiedersehen!${NC}"
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

# Root-Prüfung (optional - warnt, erzwingt aber nicht)
if [ "$EUID" -eq 0 ]; then
    echo -e "${YELLOW}⚠ Hinweis: Skript läuft als root. sudo-Befehle werden direkt ausgeführt.${NC}"
    sleep 1
fi

# Prüfe ob dnf vorhanden ist
if ! command -v dnf &>/dev/null; then
    echo -e "${RED}✗ Fehler: dnf nicht gefunden. Dieses Skript erfordert Rocky/RHEL/CentOS Linux.${NC}"
    exit 1
fi

main_menu
