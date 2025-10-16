#!/bin/bash

# clone the repo.
git clone https://github.com/Blackh-t/PI5

# Move sysytem files to systemd.
cp -f PI5/systemd/funnel.service /etc/systemd/system/      # + PORT FROWARDING.
cp -f PI5/systemd/git_pull.service /etc/systemd/system/    # + SCRIPT EXECUTER.
cp -f PI5/systemd/run_on_pull.path /etc/systemd/system/    # + CHANGE DETECTER.
cp -f PI5/systemd/run_on_pull.service /etc/systemd/system/ # + SCRIPT EXECUTER.

# Move SCRIPT to usr/local/bin
cp -f PI5/bin/git_pull.sh /usr/local/bin/
cp -f PI5/bin/run_on_pull.sh /usr/local/bin/
chmod +x /usr/local/bin/git_pull.sh
chmod +x /usr/local/bin/run_on_pull.sh

# Compile webhook.
cd PI5/dev/webhook
cargo build --release

# Activates path-watcher
systemctl daemon-reload
systemctl enable run_on_pull.path
systemctl start --now run_on_pull.path

# Activates run_on_pull service
systemctl daemon-reload
systemctl enable run_on_pull.service
systemctl start --now run_on_pull.service

# Activates git pull service
systemctl daemon-reload
systemctl enable git_pull.service
systemctl start --now git_pull.service

# Activates PORT FROWARDING
systemctl daemon-reload
systemctl enable git_pull.path
systemctl start --now git_pull.path

echo "PI5::WEBHOOK [ INSTALLED ]"
systemctl status webhook.service
