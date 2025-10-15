#!/bin/bash

# Disable Timer interrupt.
systemctl daemon-reload
systemctl disable git_pull.timer

# Load the webhook to the systemd.
cp -f /home/yoshi/git/PI5/systemd/webhook.service /etc/systemd/system/

# Build the webhook
cd /home/yoshi/git/PI5/dev/webhook
cargo build --release

# Change DIR to store the LOG.
cd /home/yoshi/PI5

# Enable webhook sever.
systemctl daemon-reload
systemctl enable webhook.service
systemctl start --now webhook.service >>PI5.log

# Load PORT forwarding service to the systemd.
cp -f /home/yoshi/git/PI5/systemd/funnel.service /etc/systemd/system/

# Enable PORT forwarding.
systemctl daemon-reload
systemctl enable funnel.service
systemctl start --now funnel.service >>PI5.log
