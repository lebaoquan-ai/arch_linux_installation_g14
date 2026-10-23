#!/usr/bin/env bash
# cbar: Screen recorder controller for Wayland / COSMIC
# deps: wf-recorder, slurp, notify-send, xdg-open, base64

set -euo pipefail

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/cbar-screenrec"
mkdir -p "${STATE_DIR}"
STATE_FILE="${STATE_DIR}/state"
REC_DIR="${HOME}/Videos/Recordings"
mkdir -p "${REC_DIR}"

NOW=$(date +%s)

PID=0
START_TIME=0
FILEPATH=""

if [[ -f "${STATE_FILE}" ]]; then
  read -r PID START_TIME FILEPATH < "${STATE_FILE}" || true
fi

RECORDING=false
if (( PID > 0 )) && kill -0 "${PID}" 2>/dev/null; then
  RECORDING=true
elif (( PID > 0 )); then
  rm -f "${STATE_FILE}"
fi

format_time() {
  local sec=$1
  local m=$((sec / 60))
  local s=$((sec % 60))
  printf "%02d:%02d" "$m" "$s"
}

# 22x22 SVG icons (rendered 2x larger than font glyphs, matching COSMIC panel height)
svg_idle='<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#f2f2f2" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="3" fill="#f2f2f2"/></svg>'
svg_rec='<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="9" stroke="#ef4444" stroke-width="2"/><circle cx="12" cy="12" r="5" fill="#ef4444"/></svg>'

b64_idle=$(printf '%s' "${svg_idle}" | base64 | tr -d '\n')
b64_rec=$(printf '%s' "${svg_rec}" | base64 | tr -d '\n')

if [[ "${RECORDING}" = "true" ]]; then
  ELAPSED=$((NOW - START_TIME))
  echo "REC $(format_time "${ELAPSED}") | image=${b64_rec}"
  echo "---"
  echo "Screen Recording in progress | disabled=true"
  echo "Elapsed: $(format_time "${ELAPSED}") | disabled=true"
  echo "File: $(basename "${FILEPATH}") | disabled=true"
  echo "---"
  echo "Stop & Save Recording | bash=/bin/bash param1=-c param2='kill -2 ${PID} && rm -f \"${STATE_FILE}\" && notify-send -i video-x-generic \"Screen Recording Saved\" \"Saved to ${FILEPATH}\"' refresh=true"
  echo "Cancel & Delete Recording | bash=/bin/bash param1=-c param2='kill -9 ${PID} 2>/dev/null; rm -f \"${STATE_FILE}\" \"${FILEPATH}\"; notify-send \"Recording Discarded\"' refresh=true"
else
  echo "Rec | image=${b64_idle}"
  echo "---"
  if command -v wf-recorder >/dev/null 2>&1; then
    START_CMD="mkdir -p \"${REC_DIR}\" && OUT=\"${REC_DIR}/recording_\$(date +%Y%m%d_%H%M%S).mp4\""
    echo "Record Full Screen | bash=/bin/bash param1=-c param2='${START_CMD} && wf-recorder -f \"\$OUT\" >/dev/null 2>&1 & echo \"\$! \$(date +%s) \$OUT\" > \"${STATE_FILE}\" && notify-send -i media-record \"Recording Started\" \"Fullscreen recording to \$OUT\"' refresh=true"
    if command -v slurp >/dev/null 2>&1; then
      echo "Record Selected Area | bash=/bin/bash param1=-c param2='${START_CMD} && GEOM=\$(slurp) && if [ -n \"\$GEOM\" ]; then wf-recorder -g \"\$GEOM\" -f \"\$OUT\" >/dev/null 2>&1 & echo \"\$! \$(date +%s) \$OUT\" > \"${STATE_FILE}\" && notify-send -i media-record \"Recording Started\" \"Area recording to \$OUT\"; fi' refresh=true"
    else
      echo "Record Selected Area (Requires slurp) | disabled=true"
    fi
    echo "Record Full Screen + Audio | bash=/bin/bash param1=-c param2='${START_CMD} && wf-recorder -a -f \"\$OUT\" >/dev/null 2>&1 & echo \"\$! \$(date +%s) \$OUT\" > \"${STATE_FILE}\" && notify-send -i media-record \"Recording Started\" \"With audio to \$OUT\"' refresh=true"
  elif command -v wl-screenrec >/dev/null 2>&1; then
    START_CMD="mkdir -p \"${REC_DIR}\" && OUT=\"${REC_DIR}/recording_\$(date +%Y%m%d_%H%M%S).mp4\""
    echo "Record Full Screen | bash=/bin/bash param1=-c param2='${START_CMD} && wl-screenrec -f \"\$OUT\" >/dev/null 2>&1 & echo \"\$! \$(date +%s) \$OUT\" > \"${STATE_FILE}\" && notify-send -i media-record \"Recording Started\" \"Fullscreen to \$OUT\"' refresh=true"
  else
    echo "wf-recorder not installed | disabled=true"
    echo "Install wf-recorder: sudo pacman -S wf-recorder slurp | disabled=true"
  fi
  echo "---"
  echo "Open Recordings Folder | shell=xdg-open param1=${REC_DIR}"
  if command -v obs >/dev/null 2>&1; then
    echo "Open OBS Studio | shell=obs"
  fi
fi
