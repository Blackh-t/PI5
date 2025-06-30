#!/usr/bin/env fish
cd
cd git/PI5

git remote update
set local_hash (git rev-parse HEAD)
set remote_hash (git rev-parse '@{u}')
set system_clock (date)

if test $local_hash != $remote_hash 
  echo "[$system_clock]--NEW COMMIT--, 🟧 PULLING..." >> gitpull/gitpull.log
  git pull >> gitpull/gitpull.log
  echo "[$(date)]--GIT PULL  --, 🟩 DONE!" >> gitpull/gitpull.log

  # Transfer files to its distination!
  rsync -av --progress /gitpull/gitpull.timer /etc/systemd/system/
  rsync -av --progress /gitpull/gitpull.service /etc/systemd/system/

  systemctl daemon-reload
  systemctl enable --now gitpull.timer
  systemctl enable --now gitpull.service
  systemctl status gitpull.service >> gitpull/gitpull.log
  systemctl status gitpull.timer >> gitpull/gitpull.log

end
 
