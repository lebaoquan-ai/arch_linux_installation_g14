#!/usr/bin/env bash
# cbar: Interactive To-Do List Popup
# deps: bash, awk, notify-send, xdg-open

set -euo pipefail

TODO_FILE="${HOME}/.config/cbar/todo.txt"
ACTION_SCRIPT="${HOME}/.config/cbar/todo_action.sh"
touch "${TODO_FILE}"

# Count active and completed tasks
ACTIVE_COUNT=$(grep -c "^\[ \]" "${TODO_FILE}" || true)
COMPLETED_COUNT=$(grep -c "^\[x\]" "${TODO_FILE}" || true)

if (( ACTIVE_COUNT > 0 )); then
  echo "✓ Todo (${ACTIVE_COUNT})"
else
  echo "✓ Todo"
fi

echo "---"
echo "Active Tasks (${ACTIVE_COUNT}) | disabled=true"

# List active tasks
LINE_NUM=1
FOUND_ACTIVE=false
while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ "$line" =~ ^\[\ \]\ (.*) ]]; then
    TASK_TEXT="${BASH_REMATCH[1]}"
    # Click to mark complete
    echo "☐ ${TASK_TEXT} | bash=/bin/bash param1=${ACTION_SCRIPT} param2=toggle param3=${LINE_NUM} refresh=true"
    FOUND_ACTIVE=true
  fi
  LINE_NUM=$((LINE_NUM + 1))
done < "${TODO_FILE}"

if [[ "${FOUND_ACTIVE}" = "false" ]]; then
  echo "No active tasks! All caught up. | disabled=true"
fi

# List completed tasks if any
if (( COMPLETED_COUNT > 0 )); then
  echo "---"
  echo "Completed (${COMPLETED_COUNT}) | disabled=true"
  LINE_NUM=1
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^\[x\]\ (.*) ]]; then
      TASK_TEXT="${BASH_REMATCH[1]}"
      # Click to unmark / restore
      echo "☑ ${TASK_TEXT} | bash=/bin/bash param1=${ACTION_SCRIPT} param2=toggle param3=${LINE_NUM} refresh=true"
    fi
    LINE_NUM=$((LINE_NUM + 1))
  done < "${TODO_FILE}"
fi

echo "---"
echo "➕ Add New Task | bash=/bin/bash param1=${ACTION_SCRIPT} param2=add refresh=true"
if (( COMPLETED_COUNT > 0 )); then
  echo "🧹 Clear Completed | bash=/bin/bash param1=${ACTION_SCRIPT} param2=clear_completed refresh=true"
fi
echo "📝 Open in Text Editor | shell=xdg-open param1=${TODO_FILE}"
