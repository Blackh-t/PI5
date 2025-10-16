#!/bin/bash

cd /home/yoshi/git/PI5/dev/webhook
cargo build --release

# cd /home/yoshi/git/PI5/systemd
# cp -f webhook.service /etc/systemd/system/

# Restart webhook service V1.0.1
systemctl deamon-reload
systemctl restart webhook.service
systemctl status webhook.service >>logger.txt
