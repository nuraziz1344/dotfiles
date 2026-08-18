#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  #
# Monitor AC/Battery power state and switch hypridle configs accordingly

CONFIG_DIR="$HOME/.config/hypr"
AC_CONFIG="$CONFIG_DIR/hypridle-ac.conf"
BATTERY_CONFIG="$CONFIG_DIR/hypridle-battery.conf"
LOG_FILE="$HOME/.cache/hypridle-monitor.log"

mkdir -p "$(dirname "$LOG_FILE")"

# Function to detect AC power state
is_on_ac() {
    if [[ -f /sys/class/power_supply/ADP0/online ]]; then
        [[ $(cat /sys/class/power_supply/ADP0/online) -eq 1 ]]
    elif [[ -f /sys/class/power_supply/ADP1/online ]]; then
        [[ $(cat /sys/class/power_supply/ADP1/online) -eq 1 ]]
    elif [[ -f /sys/class/power_supply/AC/online ]]; then
        [[ $(cat /sys/class/power_supply/AC/online) -eq 1 ]]
    else
        return 1
    fi
}

# Function to switch hypridle config
switch_hypridle() {
    local config="$1"
    local power_state="$2"

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Switching to $power_state config: $config" >> "$LOG_FILE"

    # Kill existing hypridle
    pkill -f "hypridle" 2>/dev/null
    sleep 0.5

    # Start new hypridle with appropriate config
    hypridle -c "$config" >/dev/null 2>&1 &
    disown
}

# Main monitoring loop
main() {
    local last_state=""

    while true; do
        if is_on_ac; then
            local current_state="AC"
            if [[ "$last_state" != "AC" ]]; then
                switch_hypridle "$AC_CONFIG" "AC"
                last_state="AC"
            fi
        else
            local current_state="Battery"
            if [[ "$last_state" != "Battery" ]]; then
                switch_hypridle "$BATTERY_CONFIG" "Battery"
                last_state="Battery"
            fi
        fi

        sleep 5
    done
}

# If argument is "status", just print current state and exit
if [[ "$1" == "status" ]]; then
    if is_on_ac; then
        echo "AC Power - Using AC config"
    else
        echo "Battery Power - Using Battery config"
    fi
    exit 0
fi

# Otherwise run the monitor loop
main
