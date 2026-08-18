#!/usr/bin/env bash

# Restore script for LinuxBeginnings customizations

echo "Restoring Hyprland UserKeybinds..."
cp -v hypr/UserConfigs/UserKeybinds.conf ~/.config/hypr/UserConfigs/

echo "Restoring Waybar customizations..."
cp -v waybar/configs/TOP-Default-Laptop ~/.config/waybar/configs/
cp -v waybar/ModulesGroups ~/.config/waybar/
cp -v waybar/style/Dark-Half-Moon.css ~/.config/waybar/style/

echo "Customizations restored successfully!"
echo "Reloading Waybar..."
pkill -SIGUSR2 waybar || echo "Waybar not running, skipping reload."

echo "Done!"
