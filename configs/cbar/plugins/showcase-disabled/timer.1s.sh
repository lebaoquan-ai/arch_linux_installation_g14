#!/usr/bin/env bash
# cbar: Countdown timer with alarm sound and desktop notification
# deps: bash, date, pw-play, notify-send

set -euo pipefail

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/cbar-timer"
mkdir -p "${STATE_DIR}"
STATE_FILE="${STATE_DIR}/state"
SOUND_FILE="/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga"

NOW=$(date +%s)

play_alarm() {
  if command -v pw-play >/dev/null 2>&1 && [[ -f "${SOUND_FILE}" ]]; then
    pw-play "${SOUND_FILE}" >/dev/null 2>&1 &
  elif command -v paplay >/dev/null 2>&1 && [[ -f "${SOUND_FILE}" ]]; then
    paplay "${SOUND_FILE}" >/dev/null 2>&1 &
  fi
  notify-send -u critical -i alarm-clock "Timer Expired" "Your countdown timer has finished!" >/dev/null 2>&1 || true
}

END=0
TOTAL=0
TRIGGERED=0

if [[ -f "${STATE_FILE}" ]]; then
  read -r END TOTAL TRIGGERED < "${STATE_FILE}" || true
fi

format_time() {
  local sec=$1
  local m=$((sec / 60))
  local s=$((sec % 60))
  printf "%02d:%02d" "$m" "$s"
}

if (( END > 0 )); then
  if (( NOW >= END )); then
    if [[ "${TRIGGERED}" != "1" ]]; then
      play_alarm
      echo "0 0 1" > "${STATE_FILE}"
    fi
    echo "🔔 Time's Up!"
    echo "---"
    echo "Alarm finished! | disabled=true"
    echo "Dismiss Alarm | bash=/bin/bash param1=-c param2='rm -f \"${STATE_FILE}\"' refresh=true"
    if (( TOTAL > 0 )); then
      echo "Restart (${TOTAL}s) | bash=/bin/bash param1=-c param2='echo \"\$(( \$(date +%s) + ${TOTAL} )) ${TOTAL} 0\" > \"${STATE_FILE}\"' refresh=true"
    fi
  else
    REMAINING=$((END - NOW))
    echo "⏳ $(format_time "${REMAINING}")"
    echo "---"
    echo "Active Countdown | disabled=true"
    echo "Remaining: $(format_time "${REMAINING}") | disabled=true"
    echo "Ends at: $(date -d "@${END}" +%H:%M:%S) | disabled=true"
    echo "---"
    echo "+1 Minute | bash=/bin/bash param1=-c param2='read -r e t g < \"${STATE_FILE}\" && echo \"\$((e + 60)) \$((t + 60)) 0\" > \"${STATE_FILE}\"' refresh=true"
    echo "+5 Minutes | bash=/bin/bash param1=-c param2='read -r e t g < \"${STATE_FILE}\" && echo \"\$((e + 300)) \$((t + 300)) 0\" > \"${STATE_FILE}\"' refresh=true"
    echo "Stop & Reset | bash=/bin/bash param1=-c param2='rm -f \"${STATE_FILE}\"' refresh=true"
  fi
else
  echo "⏱ Timer"
  echo "---"
  echo "Quick Timers | disabled=true"
  echo "Start 1 Min (Test) | bash=/bin/bash param1=-c param2='echo \"\$(( \$(date +%s) + 60 )) 60 0\" > \"${STATE_FILE}\"' refresh=true"
  echo "Start 5 Min | bash=/bin/bash param1=-c param2='echo \"\$(( \$(date +%s) + 300 )) 300 0\" > \"${STATE_FILE}\"' refresh=true"
  echo "Start 10 Min | bash=/bin/bash param1=-c param2='echo \"\$(( \$(date +%s) + 600 )) 600 0\" > \"${STATE_FILE}\"' refresh=true"
  echo "Start 15 Min | bash=/bin/bash param1=-c param2='echo \"\$(( \$(date +%s) + 900 )) 900 0\" > \"${STATE_FILE}\"' refresh=true"
  echo "Start 25 Min (Pomodoro) | bash=/bin/bash param1=-c param2='echo \"\$(( \$(date +%s) + 1500 )) 1500 0\" > \"${STATE_FILE}\"' refresh=true"
  echo "Start 30 Min | bash=/bin/bash param1=-c param2='echo \"\$(( \$(date +%s) + 1800 )) 1800 0\" > \"${STATE_FILE}\"' refresh=true"
  echo "Start 45 Min | bash=/bin/bash param1=-c param2='echo \"\$(( \$(date +%s) + 2700 )) 2700 0\" > \"${STATE_FILE}\"' refresh=true"
  echo "Start 60 Min | bash=/bin/bash param1=-c param2='echo \"\$(( \$(date +%s) + 3600 )) 3600 0\" > \"${STATE_FILE}\"' refresh=true"
fi
