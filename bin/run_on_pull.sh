#!/bin/bash

cd /home/yoshi/git/PI5/systemd/
cp -f run_on_pull.path /etc/systemd/system/
cp -f run_on_pull.service /etc/systemd/system/

systemctl daemon-reload
systemctl restart run_on_pull.path

systemctl daemon-reload
systemctl restart run_on_pull.service
