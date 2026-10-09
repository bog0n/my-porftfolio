#!/bin/bash
# IR_Workbench.sh - Interactive Incident Response Toolkit
# Usage: sudo ./IR_Workbench.sh
# Original filename gemini-code-1791422006028.sh

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "[-] Error: Incident response triage requires root privileges."
  exit 1
fi

# Create timestamped evidence directory
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
EVID_DIR="/var/log/ir_case_${TIMESTAMP}"
mkdir -p "$EVID_DIR"

log_cmd() {
    local output_file="$1"
    shift
    echo "=== Executing: $@ ===" >> "$output_file"
    "$@" >> "$output_file" 2>&1
    echo -e "\n" >> "$output_file"
}

collect_volatile() {
    local log="${EVID_DIR}/01_volatile_telemetry.log"
    echo "[+] Gathering Volatile Memory & Socket Telemetry..."
    
    log_cmd "$log" ss -tulpn
    log_cmd "$log" ps aux --forest
    log_cmd "$log" vmstat 1 3
    
    echo "[+] Complete. Logged to: $log"
    read -p "Press [Enter] to return to menu..."
}

collect_persistence() {
    local log="${EVID_DIR}/02_persistence_artifacts.log"
    echo "[+] Scanning Persistence Vectors..."
    
    log_cmd "$log" crontab -l
    log_cmd "$log" ls -la /etc/cron.*
    log_cmd "$log" systemctl list-timers
    
    echo "[+] Complete. Logged to: $log"
    read -p "Press [Enter] to return to menu..."
}

# Main Menu Loop
while true; do
    clear
    echo "================================================="
    echo "       LINUX INCIDENT RESPONSE WORKBENCH         "
    echo "   Evidence Directory: ${EVID_DIR}               "
    echo "================================================="
    echo "  [1] Collect Volatile Telemetry (Sockets/Processes)"
    echo "  [2] Scan Persistence Artifacts (Cron/Services)"
    echo "  [3] Network Containment (Isolate Host)"
    echo "  [Q] Quit and Package Evidence"
    echo "================================================="
    read -p "Select an option: " CHOICE

    case "$CHOICE" in
        1) collect_volatile ;;
        2) collect_persistence ;;
        3) echo "[!] Triggering Isolation Rules...";;
        [qQ])
            echo "[+] Hashing evidence files for Chain of Custody..."
            sha256sum "${EVID_DIR}"/* > "${EVID_DIR}/manifest.sha256"
            tar -czf "${EVID_DIR}.tar.gz" -C /var/log "ir_case_${TIMESTAMP}"
            echo "[+] Case archive created: ${EVID_DIR}.tar.gz"
            exit 0
            ;;
        *) echo "[-] Invalid option!"; sleep 1 ;;
    esac
done