#!/bin/bash
echo "Installing klipper-usb-copy..."

# Download the script
sudo curl -o /usr/local/bin/klipper-usb-copy.sh \
  https://raw.githubusercontent.com/Kanrog/klipper-usb-copy/main/klipper-usb-copy.sh

# Download the systemd service
sudo curl -o /etc/systemd/system/klipper-usb-copy@.service \
  https://raw.githubusercontent.com/Kanrog/klipper-usb-copy/main/klipper-usb-copy%40.service

# Download the udev rule
sudo curl -o /etc/udev/rules.d/99-klipper-usb.rules \
  https://raw.githubusercontent.com/Kanrog/klipper-usb-copy/main/99-klipper-usb.rules

# Set permissions and reload
sudo chmod +x /usr/local/bin/klipper-usb-copy.sh
sudo systemctl daemon-reload
sudo udevadm control --reload-rules

echo "Done! Plug in a USB drive to test."