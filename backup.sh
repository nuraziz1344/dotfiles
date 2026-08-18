#!/usr/bin/env bash

# Backup script for LinuxBeginnings customizations

echo "Backing up configurations..."
cp -v ~/.config/hypr/UserConfigs/UserKeybinds.conf ~/dotfiles/hypr/UserConfigs/
cp -v ~/.config/hypr/UserConfigs/WindowRules.conf ~/dotfiles/hypr/UserConfigs/
cp -v ~/.config/hypr/UserConfigs/Startup_Apps.conf ~/dotfiles/hypr/UserConfigs/
cp -v ~/.config/hypr/hypridle.conf ~/dotfiles/hypr/
cp -v ~/.config/hypr/hypridle-ac.conf ~/dotfiles/hypr/
cp -v ~/.config/hypr/hypridle-battery.conf ~/dotfiles/hypr/
mkdir -p ~/dotfiles/hypr/UserScripts
cp -v ~/.config/hypr/UserScripts/BatteryMonitor.sh ~/dotfiles/hypr/UserScripts/
cp -v ~/.config/hypr/UserScripts/PowerStateMonitor.sh ~/dotfiles/hypr/UserScripts/
cp -v ~/.config/waybar/configs/TOP-Default-Laptop ~/dotfiles/waybar/configs/
cp -v ~/.config/waybar/ModulesGroups ~/dotfiles/waybar/
cp -v ~/.config/waybar/style/Dark-Half-Moon.css ~/dotfiles/waybar/style/

echo "Configs copied successfully!"

cd ~/dotfiles || exit
git add .

if [ -z "$1" ]; then
    COMMIT_MSG="Update customizations"
else
    COMMIT_MSG="$1"
fi

# Only commit and push if there are changes
if ! git diff --cached --quiet; then
    git commit -m "$COMMIT_MSG"
    git push
    echo "Backup pushed to GitHub!"
else
    echo "No changes to backup."
fi
