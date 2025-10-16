
---

## System Feature
- Interact with the server though git commit.
Insert scrip into **`run_on_pull.sh`**
  - Example usage:
    - Enable/Disable system control services/timers
    - Create and run servers

  - How it work?
    Since the system are runnung under tailscale network, it require the timer interrupt to triggering the             **git pull service** to run the `git_pull.sh`** scrip, which pull the newest commit from this repository.
     When updates are detected on **`run_on_pull.sh`**, it tringgering a service to run the script.
---
