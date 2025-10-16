## System Features:

1.  **Interact with the server through git commit.**
    * Insert the script into `bin/run_on_pull.sh`
    * Service status [view](https://raspberrypi.ibex-mooneye.ts.net/)
    * **Common usage:**
        * Add/Remove/Enable/Disable system control services/timers/path..
        * Build/Run/create program/server/docker/Database

    **How it works:**
    * The PI 5 hosts a webhook service accessible via Tailscale Funnel. When GitHub sends a POST request, the PI executes a **git pull** and updates the systemd script, which is automatically detected and executed by another service.
    * **Workflow:**
        ` Funnel.service → webhook.service → run_on_pull.path → run_on_pull.service → ./run_on_pull.sh`

    **Example script:**
    * See commit [4fed9db](https://github.com/Blackh-t/PI5/commit/4fed9db3f7ef5e82e1da7d6b4bd8c13f57c3b576) Script for installing the Webhook service on the PI5
      
    ------------------
    **Installation**
    * Setup [tailscale](https://tailscale.com/download)
    * Set up the GitHub [webhook](https://docs.github.com/webhooks/)
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

    
