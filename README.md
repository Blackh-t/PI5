# PI5 Automated Deployment & System Management

**Status:** [View Live Status](https://raspberrypi.ibex-mooneye.ts.net/monitor/)

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

1. **Install TTYD and Btop**
   Before running the installation script, make sure **`ttyd`** and **`btop`** are installed on your system.

   a) Installing TTYD
   | Distribution | Install Command |
   | ------------------- | -------------------------------------------------- |
   | Fedora / RHEL | `sudo dnf install ttyd` |
   | Arch / Manjaro | `sudo pacman -Syu ttyd` |
   | Ubuntu / Debian | `sudo apt install ttyd` |
   | Other / From Source | See [ttyd GitHub](https://github.com/tsl0922/ttyd) |

   b) Installing Btop

   `btop` is a modern system monitoring tool. You can install it via your package manager or from source:

   | Distribution        | Install Command                                         |
   | ------------------- | ------------------------------------------------------- |
   | Fedora / RHEL       | `sudo dnf install btop`                                 |
   | Arch / Manjaro      | `sudo pacman -S btop`                                   |
   | Ubuntu / Debian     | `sudo apt install btop`                                 |
   | Other / From Source | See [btop GitHub](https://github.com/aristocratos/btop) |

---

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

Script used to install the Webhook service itself (see commit [4fed9db](https://github.com/Blackh-t/PI5/commit/4fed9db3f7ef5e82e1da7d6b4bd8c13f57c3b576)):

```bash
#!/bin/bash

# Example 1.
docker pull postgres:latest
docker run --name forwarding_table \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=admin \
  -e POSTGRES_DB=global \
  -p 65000:49000 \
  -d postgres

# Add to dashboard
create_serivce("DB", 65000, 49000, "admin") # in v1.2.1


#Example 2.
cd ~/path/to/rust
cargo build
cargo test
cargo run
```
