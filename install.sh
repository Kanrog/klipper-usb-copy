#!/bin/bash
echo "Installing klipper-usb-copy..."

# ── Auto-detect the Klipper user ─────────────────────────────────────────────
# Looks for a user that has a printer_data directory, falls back to current user
KLIPPER_USER=""
for user_home in /home/*/; do
    if [ -d "${user_home}printer_data" ]; then
        KLIPPER_USER=$(basename "$user_home")
        break
    fi
done

if [ -z "$KLIPPER_USER" ]; then
    KLIPPER_USER=$(logname 2>/dev/null || echo "$SUDO_USER")
fi

echo "Detected Klipper user: $KLIPPER_USER"
KLIPPER_HOME="/home/$KLIPPER_USER"
# ─────────────────────────────────────────────────────────────────────────────

# Download the script
sudo curl -o /usr/local/bin/klipper-usb-copy.sh \
  https://raw.githubusercontent.com/Kanrog/klipper-usb-copy/main/klipper-usb-copy.sh

# Download the systemd service
sudo curl -o /etc/systemd/system/klipper-usb-copy@.service \
  https://raw.githubusercontent.com/Kanrog/klipper-usb-copy/main/klipper-usb-copy%40.service

# Download the udev rule
sudo curl -o /etc/udev/rules.d/99-klipper-usb.rules \
  https://raw.githubusercontent.com/Kanrog/klipper-usb-copy/main/99-klipper-usb.rules

# Patch the script with the correct user paths
sudo sed -i "s|/home/pi|$KLIPPER_HOME|g" /usr/local/bin/klipper-usb-copy.sh
echo "Patched paths for user: $KLIPPER_USER"

# Set permissions and reload
sudo chmod +x /usr/local/bin/klipper-usb-copy.sh
sudo systemctl daemon-reload
sudo udevadm control --reload-rules

read -p "Installation complete! Reboot now? (recommended) [y/N]: " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    sudo reboot
else
    echo "Skipping reboot. If USB detection doesn't work, try rebooting manually."
fi
