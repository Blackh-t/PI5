#!/bin/bash

# Move to systemd/system
# system files
cp -f git/PI5/systemd/run_on_pull.path /etc/systemd/system/
cp -f git/PI5/systemd/run_on_pull.service /etc/systemd/system/

# Move to usr/local/bin
# scrips
cp -f git/PI5/bin/run_on_pull.sh /usr/local/bin/
chmod +x /usr/local/bin/run_on_pull.sh

# Activates path-watcher
sudo systemctl daemon-reload
sudo systemctl enable --now run_on_pull.path
