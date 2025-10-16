#!/bin/bash

cd /home/yoshi/git/PI5/dev/webhook
cargo build --release

systemctl daemon-reload
systemctl restart webhook.service
