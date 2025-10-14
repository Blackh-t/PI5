#!/bin/bash

# Load timer to the systemctl
cd /home/yoshi/git/PI5/systemd/
cp -f git_pull.timer /etc/systemd/system/

sudo systemctl daamon-load
sudo systemctl restart git_pull.timer
sudo systemctl status git_pull.timer >> logger.txt
