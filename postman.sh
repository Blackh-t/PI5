#!/bin/bash
set -e # Stop on error flag.

#             CONFIG                  
#######################################
IP="127.0.0.1"
WS_PORT=7777 # PORT TO BE FORWARDING.
BTOP_PORT=7778 # PORT FOR glances.
SERVER_ENDPOINT=""
SECRET_TOKEN=""
SERVICE_NAME="pi5_dash"
BIN_DIR="/opt/$SERVICE_NAME"
WORK_DIR=$(pwd)
SYSTEMD_LIST=$WORK_DIR"/systemd.txt"


#        INSTALL TAILSCALE            
#######################################
curl -fsSL https://tailscale.com/install.sh | sh
sudo systemctl enable --now tailscaled
sudo tailscale login
sudo tailscale up


# Init SECRET_TOKEN for Github webhook. 
if [ -z "$SECRET_TOKEN" ]; then
    echo "SECRET_TOKEN for Github Webhook is Undefined! More info visit: https://docs.github.com/en/webhooks/using-webhooks/creating-webhooks"
    read -p "Type the SECRET_TOKEN: " SECRET_TOKEN
fi

#       funnel_webserver.services
#######################################
echo "📦 Generates Funnel Service..."
echo "funnel_webserver.service" >>systemd.txt
sudo tee /etc/systemd/system/funnel_webserver.service >/dev/null <<EOF
[Unit]
Description=Funnel WebServer (Port $WS_PORT)
After=network-online.target tailscaled.service
Requires=tailscaled.service

[Service]
Type=simple
User=root
ExecStart=/usr/bin/tailscale funnel --bg --set-path / http://127.0.0.1:$WS_PORT
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

#       funnel_btop.services
#######################################
echo "funnel_btop.service" >>systemd.txt
sudo tee /etc/systemd/system/funnel_btop.service >/dev/null <<EOF
[Unit]
Description=Funnel Btop (Port $BTOP_PORT)
After=network-online.target tailscaled.service
Requires=tailscaled.service

[Service]
Type=simple
User=root
ExecStart=/usr/bin/tailscale funnel --bg --set-path /btop http://127.0.0.1:$BTOP_PORT
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF


#       btop.service
#######################################
TTYD_PATH=$(which ttyd)

echo "📦 Generates Btop Service..."
echo "btop.service" >>systemd.txt
sudo tee /etc/systemd/system/btop.service >/dev/null <<EOF
[Unit]
Description=Btop service
After=network.target

[Service]
User=root
ExecStart=$TTYD_PATH -p $BTOP_PORT btop
Restart=always

[Install]
WantedBy=multi-user.target
EOF

#       webserver.service
#######################################
echo "📦 Generates WebServer Service..."
echo "webserver.service" >>systemd.txt
sudo tee /etc/systemd/system/webserver.service >/dev/null <<EOF
[Unit]
Description=Run webserver.

[Service]
User=root
WorkingDirectory=$WORK_DIR/dev/webapp/http_server/
ExecStart=$BIN_DIR/http_server
Restart=always
Environment="TS_IP=$IP"
Environment="TS_PORT=$PORT"
Environment="SCRIPT_PATH=$WORK_DIR/bin/git_pull.sh"
Environment="SECRET_TOKEN=$SECRET_TOKEN"

[Install]
WantedBy=multi-user.target
EOF

#       run_on_pull.path
#######################################
echo "📦 Generates Path Detecter Service..."
echo "run_on_pull.path" >>systemd.txt
sudo tee /etc/systemd/system/run_on_pull.path >/dev/null <<EOF
[Unit]
Description=Detecting change on "run_on_pull.sh".

[Path]
PathModified=/usr/local/bin/run_on_pull.sh
Unit=run_on_pull.service

[Install]
WantedBy=multi-user.target 
EOF

#       run_on_pull.service
#######################################
sudo tee /etc/systemd/system/run_on_pull.service >/dev/null <<EOF
[Unit]
Description=run script: run_on_pull
ConditionPathExists=/usr/local/bin/run_on_pull.sh

[Service]
Type=oneshot
User=root
WorkingDirectory=$WORK_DIR
Environment="PATH=/root/.cargo/bin:/usr/bin:/bin"
ExecStart=/usr/local/bin/run_on_pull.sh
RemainAfterExit=false
EOF

echo "📦 Installing $SERVICE_NAME..."

# Compile webserver
curl https://sh.rustup.rs -sSf | sh
cd dev/webapp/http_server
export PATH="/root/.cargo/bin:$PATH"
cargo build --release

sudo mkdir -p $BIN_DIR
sudo cp -r ./target/release/http_server $BIN_DIR/

# Activates services
sudo systemctl daemon-reload
while IFS= read -r SERVICE_NAME; do
    sudo systemctl enable "$SERVICE_NAME"
    sudo systemctl start "$SERVICE_NAME"
done < "$SYSTEMD_LIST"

# Updates the endpoint for client-side. 
echo "📦 Configure client-side endpoint..."
systemctl status btop.service
read -p "Type the hostname (example: https://hostname.ts.net): " SERVER_ENDPOINT

sudo tee -a dev/monitor_app/script.js >/dev/null <<EOF
iframe.src = "$SERVER_ENDPOINT/btop";
EOF 

# Move SCRIPT to usr/local/bin
cp -f $WORK_DIR/bin/git_pull.sh /usr/local/bin/
cp -f $WORK_DIR/bin/run_on_pull.sh /usr/local/bin/
chmod +x /usr/local/bin/git_pull.sh
chmod +x /usr/local/bin/run_on_pull.sh

cd $WORK_DIR/dev/webapp/http_server
cargo clean

echo "✅ Installation complete!"
