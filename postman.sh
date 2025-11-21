#!/bin/bash
set -e # Stop on error flag.

#### CONFIG ####
IP="127.0.0.1"
PORT=3000 # PORT TO BE FORWARDING.
SECRET_TOKEN=""
SERVICE_NAME="pi5_dash"
BIN_DIR="/opt/$SERVICE_NAME"
WORK_DIR=$(pwd)
SYSTEMD_LIST="systemd.txt"

################

# Installing tailscale
curl -fsSL https://tailscale.com/install.sh | sh
sudo systemctl enable --now tailscaled
sudo tailscale login
sudo tailscale up

# Init SECRET_TOKEN for .
if [ -z "$SECRET_TOKEN" ]; then
    echo "SECRET_TOKEN for Github Webhook is Undefined! More info visit: https://docs.github.com/en/webhooks/using-webhooks/creating-webhooks"
    read -p "Type the SECRET_TOKEN: " SECRET_TOKEN
fi

# Generate services
echo "📦 Generates Funnel Service..."
echo "funnel.service" >>systemd.txt
sudo tee /etc/systemd/system/funnel.service >/dev/null <<EOF
[Unit]
Description=FORWARDING PORT $PORT

[Service]
ExecStart=/usr/bin/tailscale funnel 3000
Restart=always

[Install]
WantedBy=multi-user.target
EOF

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

echo "run_on_pull.service" >>systemd.txt
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

echo "📦 Generates WebServer Service..."
echo "webserver.service" >>systemd.txt
sudo tee /etc/systemd/system/webserver.service >/dev/null <<EOF
[Unit]
Description=Run webserver.

[Service]
User=root
WorkingDirectory=$WORK_DIR
ExecStart=$WORK_DIR/dev/webapp/http_server/target/release/http_server
Restart=always
Environment="TS_IP=$IP"
Environment="TS_PORT=$PORT"
Environment="SCRIPT_PATH=$WORK_DIR/bin/git_pull.sh"
Environment="SECRET_TOKEN=$SECRET_TOKEN"

[Install]
WantedBy=multi-user.target
EOF

echo "📦 Generates Btop Service..."
echo "btop.service" >>systemd.txt
sudo tee /etc/systemd/system/btop.service >/dev/null <<EOF
[Unit]
Description=btop terminal via ttyd
After=network.target

[Service]
User=root
ExecStart=/usr/bin/ttyd -p 7777 btop
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "📦 Installing $SERVICE_NAME..."

# Compile webserver
curl https://sh.rustup.rs -sSf | sh
cd dev/webapp/http_server
export PATH="/root/.cargo/bin:$PATH"
cargo build --release

sudo mkdir -p $INSTALL_DIR
sudo cp -r ./target/release/http_server $INSTALL_DIR/

# Activates services
sudo systemctl daemon-reload

while IFS= read -r SERVICE_NAME; do
    sudo systemctl enable $SERVICE_NAME
    sudo systemctl start $SERVICE_NAME
    sudo systemctl status $SERVICE_NAME
done <"$SERVICE_FILE"

# Move SCRIPT to usr/local/bin
cp -f $WORK_DIR/bin/git_pull.sh /usr/local/bin/
cp -f $WORK_DIR/bin/run_on_pull.sh /usr/local/bin/
chmod +x /usr/local/bin/git_pull.sh
chmod +x /usr/local/bin/run_on_pull.sh

echo "✅ Installation complete!"
