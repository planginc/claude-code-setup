#!/bin/bash
# SessionStart hook: fires when a Claude Code session begins.
#
# - Known project directory: injects retrieval instructions so Claude scans
#   last session notes automatically before responding.
# - Unknown directory: asks which project to work on from a numbered list.
#
# SETUP: Replace all [YOUR_*] placeholders below with your own values.
# - [YOUR_HOME]: your home directory, e.g. /Users/yourname
# - [YOUR_PROJECT_ID]: your Convex project ID for that project (or leave blank)
# - Add/remove projects in the case statement and the picker list.

# ---------------------------------------------------------------------------
# Map directories to "Project Name|ConvexProjectID"
# Leave the ID blank (no value after |) if you don't use Convex for that project.
# ---------------------------------------------------------------------------
get_project_info() {
  local pwd="$1"
  case "$pwd" in
    [YOUR_HOME]/Documents/my-app*)
      echo "My App|[YOUR_PROJECT_ID]"
      ;;
    [YOUR_HOME]/Documents/another-project*)
      echo "Another Project|"
      ;;
    # Add more projects here following the same pattern.
    *)
      echo ""
      ;;
  esac
}

PROJECT_INFO=$(get_project_info "$PWD")

if [[ -z "$PROJECT_INFO" ]]; then
  # Unknown directory -- show the numbered project picker.
  # Update this list to match your projects above.
  python3 << 'PYEOF'
import json

# UPDATE THIS LIST to match your projects
cheat = """#1 My App
#2 Another Project
#3 Add more projects here"""

# UPDATE THIS MAP with your Convex project IDs (or remove if not using Convex)
project_map = (
    "  #1 My App: [YOUR_PROJECT_ID]\n"
    "  #2 Another Project: (no ID)\n"
    "  #3 ...: ..."
)

# UPDATE THIS MAP with your folder paths
folder_map = (
    "  #1 My App: [YOUR_HOME]/Documents/my-app\n"
    "  #2 Another Project: [YOUR_HOME]/Documents/another-project\n"
    "  #3 ...: ..."
)

context = (
    "IMPORTANT: The session started outside a recognized project directory. "
    "Your FIRST message must be ONLY this numbered list -- nothing else before or after it:\n\n"
    "Which project?\n\n" + cheat + "\n\n"
    "Reply with a number.\n\n"
    "When the user replies with a number, that is their project selection. "
    "Do NOT say anything else. Do NOT acknowledge the number. "
    "IMMEDIATELY run ALL of these in sequence:\n"
    "  1. Check your note storage for recent session notes\n"
    "  2. Read the HANDOVER.md file from the project folder (see folder map below). "
    "If HANDOVER.md exists, include its contents in the session summary.\n"
    "Filter results for noteType: session_log, troubleshooting, technical_solution, breakthrough.\n"
    "Present a 2-3 line summary of last session (combining notes and HANDOVER.md), "
    "list remaining backlog items numbered, "
    "end with: Which one do you want to tackle? Do NOT start building until the user picks.\n\n"
    "Project IDs:\n" + project_map + "\n\n"
    "Project folders (for HANDOVER.md):\n" + folder_map
)

print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": context
    }
}))
PYEOF
  exit 0
fi

# Known project directory -- inject retrieval instructions
PROJECT_NAME=$(echo "$PROJECT_INFO" | cut -d'|' -f1)
PROJECT_ID=$(echo "$PROJECT_INFO" | cut -d'|' -f2)

if [[ -n "$PROJECT_ID" ]]; then
  RETRIEVAL_INSTRUCTION="Project ID: $PROJECT_ID. Run compound retrieval for this project. Filter results for noteType in session_log, troubleshooting, technical_solution, breakthrough."
else
  RETRIEVAL_INSTRUCTION="No project ID. Search notes by project name: $PROJECT_NAME."
fi

MESSAGE="Session started in $PWD ($PROJECT_NAME project). BEFORE responding or asking questions: (1) run compound retrieval to surface what was done last time. $RETRIEVAL_INSTRUCTION (2) Read HANDOVER.md in $PWD if it exists -- this is the single most important file for picking up where we left off. Present a 2-3 line summary combining notes and HANDOVER.md, then list remaining backlog items numbered. End with: Which one do you want to tackle? Do NOT start building anything until the user picks."

python3 -c "
import json, sys
msg = sys.argv[1]
project = sys.argv[2]
output = {
  'systemMessage': msg,
  'hookSpecificOutput': {
    'hookEventName': 'SessionStart',
    'additionalContext': 'Auto-retrieval triggered for project: ' + project
  }
}
print(json.dumps(output))
" "$MESSAGE" "$PROJECT_NAME"
