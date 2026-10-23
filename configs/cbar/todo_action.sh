#!/usr/bin/env bash
set -euo pipefail

TODO_FILE="${HOME}/.config/cbar/todo.txt"
touch "${TODO_FILE}"

cmd="${1:-}"

case "${cmd}" in
  toggle)
    line_num="${2:-0}"
    if (( line_num > 0 )); then
      awk -v target="${line_num}" '
        NR == target {
          if ($0 ~ /^\[ \]/) {
            sub(/^\[ \]/, "[x]");
          } else if ($0 ~ /^\[x\]/) {
            sub(/^\[x\]/, "[ ]");
          }
        }
        { print }
      ' "${TODO_FILE}" > "${TODO_FILE}.tmp" && mv "${TODO_FILE}.tmp" "${TODO_FILE}"
    fi
    ;;

  add)
    if command -v zenity >/dev/null 2>&1; then
      new_task=$(zenity --entry --title="cbar To-Do" --text="Enter new task description:" 2>/dev/null || true)
      if [[ -n "${new_task// }" ]]; then
        echo "[ ] ${new_task}" >> "${TODO_FILE}"
        notify-send -i task-due "Task Added" "${new_task}" 2>/dev/null || true
      fi
    else
      # Fallback: prompt via a small terminal window
      cosmic-terminal -e bash -c 'read -rp "Enter new task: " task && [ -n "$task" ] && echo "[ ] $task" >> "'"${TODO_FILE}"'"' 2>/dev/null || true
    fi
    ;;

  clear_completed)
    grep -v "^\[x\]" "${TODO_FILE}" > "${TODO_FILE}.tmp" 2>/dev/null || true
    mv "${TODO_FILE}.tmp" "${TODO_FILE}"
    notify-send -i edit-clear "To-Do" "Cleared completed tasks" 2>/dev/null || true
    ;;

  *)
    echo "Usage: $0 {toggle <line>|add|clear_completed}"
    exit 1
    ;;
esac
