# klipper-usb-copy

Automatically copies G-code files from a USB drive to your Klipper printer when you plug it in — no computer required.

## What it does

When you plug a USB drive into your printer, this tool will:

1. Detect the USB drive
2. Scan it for G-code files (`.gcode`, `.g`, `.gc`, `.gco`)
3. Copy any new or updated files into Klipper's gcode folder
4. Eject the drive safely

Folder structure from the USB is preserved, unchanged files are skipped, and everything is logged to `/var/log/klipper-usb-copy.log` so you can see exactly what happened.

## Installation

Make sure your printer is connected to the internet, then SSH into it and run:

```bash
bash <(curl -s https://raw.githubusercontent.com/Kanrog/klipper-usb-copy/main/install.sh)
```

That's it! The install script will download and set up everything automatically.

> **Note:** If you're not sure how to SSH in, you'll need your printer's IP address (find it in your router's device list) and an SSH client. On Windows, [PuTTY](https://www.putty.org/) is a good option.

## Troubleshooting

**Files aren't being copied when I plug in the USB**
- Check the log to see what happened: `cat /var/log/klipper-usb-copy.log`
- Make sure your G-code files have a supported extension: `.gcode`, `.g`, `.gc`, or `.gco`
- Try unplugging and replugging the USB drive

**The install command fails**
- Make sure your printer is connected to the internet
- Double-check that you're logged in as a user with `sudo` access

**Files are copied to the wrong folder**
- The default gcode folder is `/home/pi/printer_data/gcodes`. If your setup is different, open the script and update the `KLIPPER_GCODE_DIR` line at the top:
  ```bash
  sudo nano /usr/local/bin/klipper-usb-copy.sh
  ```

**I want to undo the installation**
```bash
sudo rm /usr/local/bin/klipper-usb-copy.sh
sudo rm /etc/systemd/system/klipper-usb-copy@.service
sudo rm /etc/udev/rules.d/99-klipper-usb.rules
sudo systemctl daemon-reload
sudo udevadm control --reload-rules
```
