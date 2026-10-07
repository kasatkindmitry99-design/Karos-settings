#!/bin/bash

# ================= НАСТРОЙКИ =================
X_COORD=611
Y_COORD=27
BUFF_HEX="#F986DD" 
# =============================================

human_sleep() {
    local min=$1
    local max=$2
    local sleep_time=$(awk -v min="$min" -v max="$max" 'BEGIN{srand(); print min+rand()*(max-min)}')
    sleep "$sleep_time"
}

press_key_human() {
    local key=$1
    xdotool keydown "$key" 2>/dev/null
    human_sleep 0.05 0.12
    xdotool keyup "$key" 2>/dev/null
}

get_pixel_hex() {
    maim -g 1x1+${X_COORD}+${Y_COORD} /tmp/pixel.png 2>/dev/null
    convert /tmp/pixel.png -depth 8 txt: 2>/dev/null | awk 'NR==2 {print $3}' | cut -c1-7
}

sleep 3

while true; do
    CURRENT_HEX=$(get_pixel_hex)

    if [ "${CURRENT_HEX,,}" != "${BUFF_HEX,,}" ]; then
        human_sleep 0.3 0.7

        press_key_human "2"

        human_sleep 0.4 0.8

        press_key_human "3"

        human_sleep 0.25 0.5

        press_key_human "3"

        sleep 2
    fi

    human_sleep 0.8 1.3
done