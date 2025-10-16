#!/bin/bash
# Simple service status checker

# Systemd services directory
SERVICE_DIR="/home/yoshi/git/PI5/systemd"

# Fetch systemctl files.
SERVICES=($(ls "$SERVICE_DIR" 2>/dev/null | xargs -n 1 basename))

echo "=== Service Status ==="

for SERVICE in "${SERVICES[@]}"; do
    if systemctl is-active --quiet "$SERVICE"; then
        printf "[ OK  ] %-20s is running\n" "$SERVICE"
    else
        printf "[ ERR ] %-20s is NOT running\n" "$SERVICE"
        printf "   |\n>>>>>>> %-20s\n" "$SERVICE"
        systemctl status "$SERVICE"
        printf "<<<<<<<\n   |\n"
    fi
done

echo "======================="
