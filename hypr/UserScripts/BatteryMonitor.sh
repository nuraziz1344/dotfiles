#!/usr/bin/env bash
# /* ---- 💫 Battery Monitor with custom thresholds */  #

BATTERY_PATH="/sys/class/power_supply/BAT0"
LOG_FILE="$HOME/.cache/battery-monitor.log"
NOTIFICATION_ICON="$HOME/.config/swaync/images/ja.png"

mkdir -p "$(dirname "$LOG_FILE")"

NOTIFIED_30=false
NOTIFIED_25=false
NOTIFIED_20=false
NOTIFIED_15=false
NOTIFIED_5=false

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

send_notification() {
    local urgency="$1"
    local title="$2"
    local message="$3"
    notify-send -i "$NOTIFICATION_ICON" -u "$urgency" "$title" "$message"
    log "$title: $message"
}

is_ac_online() {
    if [[ -f /sys/class/power_supply/ADP0/online ]] && [[ $(cat /sys/class/power_supply/ADP0/online) -eq 1 ]]; then
        return 0
    elif [[ -f /sys/class/power_supply/AC/online ]] && [[ $(cat /sys/class/power_supply/AC/online) -eq 1 ]]; then
        return 0
    else
        return 1
    fi
}

main() {
    log "Battery monitor started"

    while true; do
        if is_ac_online; then
            NOTIFIED_30=false
            NOTIFIED_25=false
            NOTIFIED_20=false
            NOTIFIED_15=false
            NOTIFIED_5=false
            sleep 10
            continue
        fi

        if [[ ! -f "$BATTERY_PATH/capacity" ]]; then
            sleep 10
            continue
        fi

        local capacity=$(cat "$BATTERY_PATH/capacity")
        local status=$(cat "$BATTERY_PATH/status")

        if [[ "$status" != "Discharging" ]]; then
            NOTIFIED_30=false
            NOTIFIED_25=false
            NOTIFIED_20=false
            NOTIFIED_15=false
            NOTIFIED_5=false
            sleep 10
            continue
        fi

        # 30% threshold
        if [[ $capacity -le 30 ]] && [[ $capacity -gt 25 ]] && [[ "$NOTIFIED_30" == false ]]; then
            send_notification "normal" "🔋 Battery Low" "Battery is at ${capacity}%"
            NOTIFIED_30=true
        fi

        # 25% threshold
        if [[ $capacity -le 25 ]] && [[ $capacity -gt 20 ]] && [[ "$NOTIFIED_25" == false ]]; then
            send_notification "normal" "⚠️ Battery Low" "Battery is at ${capacity}%"
            NOTIFIED_25=true
        fi

        # 20% threshold - sleep, notify 10s before, dismissable
        if [[ $capacity -le 20 ]] && [[ $capacity -gt 15 ]] && [[ "$NOTIFIED_20" == false ]]; then
            NOTIFIED_20=true
            log "Battery at 20%, triggering 10s sleep countdown (dismissable)"
            local action=$(notify-send -i "$NOTIFICATION_ICON" -u critical -t 10000 --action="cancel=Cancel Sleep" "💤 Suspend Warning" "Battery at 20%. Suspending in 10s...")
            
            if [[ "$action" == "cancel" ]]; then
                log "User canceled suspend at 20%"
            else
                if ! is_ac_online; then
                    log "Suspending at 20%"
                    systemctl suspend
                fi
            fi
        fi

        # 15% threshold - sleep, notify 5s before, not dismissable
        if [[ $capacity -le 15 ]] && [[ $capacity -gt 5 ]] && [[ "$NOTIFIED_15" == false ]]; then
            NOTIFIED_15=true
            log "Battery at 15%, triggering 5s sleep countdown (not dismissable)"
            notify-send -i "$NOTIFICATION_ICON" -u critical -t 5000 "💤 Mandatory Suspend" "Battery at 15%. Suspending in 5s..."
            sleep 5
            
            if ! is_ac_online; then
                log "Suspending at 15%"
                systemctl suspend
            fi
        fi

        # 5% threshold - shutdown, notify 10s before
        if [[ $capacity -le 5 ]] && [[ "$NOTIFIED_5" == false ]]; then
            NOTIFIED_5=true
            log "Battery at 5%, triggering 10s shutdown countdown"
            notify-send -i "$NOTIFICATION_ICON" -u critical -t 10000 "🔴 Emergency Shutdown" "Battery at 5%. Shutting down in 10s..."
            sleep 10
            
            if ! is_ac_online; then
                log "Shutting down at 5%"
                systemctl poweroff
            fi
        fi

        sleep 5
    done
}

main
