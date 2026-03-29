#!/bin/bash
# PostToolUse: Edit, Write
# Fires when the global CLAUDE.md is modified.
# Blocks Claude from continuing until it confirms the change is synced to
# any secondary instruction surfaces (e.g., Claude Desktop custom instructions).
#
# SETUP: Replace [YOUR_HOME] with your home directory path.

INPUT=$(cat)
FILE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null || echo "")

if [ "$FILE" = "[YOUR_HOME]/.claude/CLAUDE.md" ]; then
  cat <<'EOF'
GLOBAL CLAUDE.md EDITED. STOP before continuing.

1. Tell the user specifically what you just changed in CLAUDE.md (one sentence, the rule itself).
2. Tell them: "I need to apply the same change to any secondary instruction surfaces. Here is exactly what I will edit: [quote the specific line or section]."
3. Wait for the user to reply and confirm before touching secondary instruction files.
4. Make only that surgical change. Do not overwrite or reformat surrounding content.
5. After editing, remind the user to sync the change to Claude Desktop or any other surfaces.

Do not proceed past this point until step 3 is complete.
EOF
  exit 2
fi

exit 0
