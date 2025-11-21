# 🌟 PI5 Automated Deployment & System Management

**Status:** [View Live Status](https://raspberrypi.ibex-mooneye.ts.net/)

---

## 📁 Directory Structure

| Directory     | Content                   | Description                          |
| :------------ | :------------------------ | :----------------------------------- |
| `bin`         | `.sh` scripts             | Contains various **shell scripts**   |
| `dev`         | `webserver`               | Development files for **subsystems** |
| `systemd.txt` | active systemd units list |
| `postman.sh`  | Installer script          | The **main installation script**     |

---

## ✨ Feature 1: Trigger Server Actions via Git Commits (Webhooks)

The **Raspberry Pi 5** hosts a webhook service, accessible externally via **Tailscale Funnel**. When a new commit is pushed to the GitHub repository, GitHub sends a **POST** request to the service.

Upon receiving the request, the PI executes a `git pull` and updates the relevant configuration. This systemd script update is automatically detected and executed by a separate service, enabling **automated system changes**.

### Common Usage Scenarios

- **System Control:** Add, remove, enable, or disable system control services, timers, or paths.
- **Deployment:** Automatically build, run, or create programs, servers, Docker containers, or databases.

### Installation

1. **Install TTYD**
   Make sure `ttyd` is installed before running the script. Use the command for your distribution:

   | Distribution        | Install Command                                    |
   | ------------------- | -------------------------------------------------- |
   | Debian / Ubuntu     | `sudo apt update && sudo apt install ttyd`         |
   | Fedora / RHEL       | `sudo dnf install ttyd`                            |
   | Arch / Manjaro      | `sudo pacman -Syu ttyd`                            |
   | Other / From Source | See [ttyd GitHub](https://github.com/tsl0922/ttyd) |

2. **Clone the Repository:**

   ```bash
   git clone https://github.com/Blackh-t/PI5
   ```

3. **Run the Installer Script:**
   ```bash
   cd PI5
   ./postman.sh
   ```
   > **Note:** If you encounter a permission error, you may need to grant execute permissions first: `chmod +x postman.sh`.

### Example Installation Script

This example shows the script used to install the Webhook service itself (see commit [4fed9db](https://github.com/Blackh-t/PI5/commit/4fed9db3f7ef5e82e1da7d6b4bd8c13f57c3b576)):

```bash
#!/bin/bash

# Disable and stop the git pull timer for safety
systemctl daemon-reload
systemctl disable git_pull.timer

# Load the webhook service to the systemd directory
cp -f /home/yoshi/git/PI5/systemd/webhook.service /etc/systemd/system/

# Build the webhook executable
cd /home/yoshi/git/PI5/dev/webhook
cargo build --release

# Change directory to store logs
cd /home/yoshi/PI5

# Enable and start the webhook server
systemctl daemon-reload
systemctl enable webhook.service
systemctl start --now webhook.service >>PI5.log

# Load the Tailscale Funnel service (for port forwarding) to systemd
cp -f /home/yoshi/git/PI5/systemd/funnel.service /etc/systemd/system/

# Enable and start the PORT forwarding service
systemctl daemon-reload
systemctl enable funnel.service
systemctl start --now funnel.service >>PI5.log

```
