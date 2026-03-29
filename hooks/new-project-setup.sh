#!/bin/bash
# PostToolUse: Bash
# Fires after mkdir commands that create a top-level project folder.
# Blocks until Claude confirms required project setup is complete.
#
# SETUP: Update the path pattern in the grep below to match where you keep your projects.
# Default assumes ~/Documents/ and your home directory's top level.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")

# Only fire on mkdir commands
if ! echo "$COMMAND" | grep -q 'mkdir'; then
  exit 0
fi

# Only fire if creating a top-level project directory (not subdirs, build artifacts, etc.)
# Update this pattern to match your project folder locations.
HOME_DIR="$HOME"
if ! echo "$COMMAND" | grep -qE "mkdir[^;]*($HOME_DIR/Documents/[^/ ]+\s*$|$HOME_DIR/Documents/[^/ ]+\"?\s*$)"; then
  exit 0
fi

# Skip known non-project patterns
if echo "$COMMAND" | grep -qE 'node_modules|\.next|dist/|build/|\.cache|tmp|temp|__pycache__'; then
  exit 0
fi

cat <<'EOF'
New top-level project folder detected. Complete full setup before continuing:

1. git init [new-folder]
2. Create CLAUDE.md (purpose, stack, rules, pitfalls, current state)
3. Create README.md (what it is, how to set it up, how to run it)
4. Create HANDOVER.md (blank for now -- will be written at first session end)
5. git add . && git commit -m "Initial project setup"
6. Add folder to ~/.claude/hooks/session-start.sh project map

All six steps are required. Do not proceed with project work until done.
EOF
exit 2
