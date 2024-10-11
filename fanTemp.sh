#!/bin/bash

# Run this script with sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)" 
   exit 1
fi

# Install required packages
apt update
apt install -y git build-essential

# Clone mbpfan repository
git clone https://github.com/linux-on-mac/mbpfan.git
cd mbpfan

# Build and install mbpfan
make
make install

# Create custom configuration file
cat > /etc/mbpfan.conf <<EOL
[general]
min_fan_speed = 2000    # Minimum fan speed
max_fan_speed = 6200    # Maximum fan speed
low_temp = 63           # If temperature is below this, fan speed will be at minimum
high_temp = 66          # If temperature is above this, fan speed will be at maximum
max_temp = 86           # If temperature is above this, fan speed will be at maximum
polling_interval = 1    # Polling interval in seconds
EOL

# Create systemd service file
cat > /etc/systemd/system/mbpfan.service <<EOL
[Unit]
Description=mbpfan daemon
After=syslog.target

[Service]
Type=simple
ExecStart=/usr/sbin/mbpfan -f
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd, enable and start mbpfan service
systemctl daemon-reload
systemctl enable mbpfan
systemctl start mbpfan

# Check status
systemctl status mbpfan
