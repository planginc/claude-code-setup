#!/bin/bash
# PostToolUse hook: scans written/edited .html files for em dashes (U+2014).
# Em dashes in public-facing HTML signal AI-written text. This hook blocks on detection.
# Fires after Write and Edit tool calls.

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
tool_input = data.get('tool_input', {})
print(tool_input.get('file_path', ''))
" 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Only scan .html files. Internal files (.sh, .ts, .js, .md, .json, config) are fine.
if [[ "$FILE_PATH" != *.html ]]; then
  exit 0
fi

MATCHES=$(grep -n "—" "$FILE_PATH" 2>/dev/null)

if [ -n "$MATCHES" ]; then
  echo "EM DASH DETECTED in $FILE_PATH"
  echo ""
  echo "Em dashes are banned in public-facing content. Replace with commas, periods, colons, or restructure the sentence."
  echo ""
  echo "Lines with em dashes:"
  echo "$MATCHES"
  echo ""
  echo "Fix these before continuing."
  exit 2
fi

exit 0
