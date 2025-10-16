# PI5-System Features
PI5-SF status [view](https://raspberrypi.ibex-mooneye.ts.net/)

## /// DIRECTORIES  ////////////////////////////////////////////////////
* bin - Scripts : `.sh`
* dev - Subsystem : `webserver`
* systemd - System config: `timer, service..`
* inactive_systemd - Not in use system.
* **!postman.sh** - Installer!

## /// Feature 1 -- Trigger server actions via Git commits 
The PI 5 hosts a webhook service accessible via Tailscale Funnel. When GitHub sends a POST request, the PI executes a git pull and updates the systemd script, which is automatically detected and executed by another service

### Common usage
* Add/Remove/Enable/Disable system control services/timers/path..
* Build/Run/create program/server/docker/Database
### **Example script:**
  See commit [4fed9db](https://github.com/Blackh-t/PI5/commit/4fed9db3f7ef5e82e1da7d6b4bd8c13f57c3b576) Script for installing the Webhook service on the PI5
```bash
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
```

### **Installation**
* Setup [tailscale](https://tailscale.com/download) and GitHub [webhook](https://docs.github.com/webhooks/)
* Update systemd service configurations
  * `PI5/systemd/webhook.service`:
    * Update `ExecStart` to point to Rust release binary
    * Add `SCRIPT_PATH` pointing to `git_pull.sh`
    * Include `SECRET_TOKEN` for webhook validation
  * `PI5/systemd/run_on_pull.service`:
    * Set `WorkingDirectory` to repository root (optional)
   
* **Run the script.**
    ```bash
      ./postman.sh
    ```
