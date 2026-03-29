#!/bin/bash
# PreToolUse: Bash
# Verifies git user.email is set to a GitHub-recognized address before any push.
# Prevents "Deployment Blocked: could not associate committer" errors in Vercel.
#
# SETUP: Replace [YOUR_GITHUB_NOREPLY_EMAIL] with your actual GitHub no-reply email.
# Find it at https://github.com/settings/emails (look for the @users.noreply.github.com address).

TOOL_INPUT="$CLAUDE_TOOL_INPUT"

# Only fire on git push commands
if ! echo "$TOOL_INPUT" | grep -q "git push"; then
  exit 0
fi

GIT_EMAIL=$(git config user.email 2>/dev/null)

if [ -z "$GIT_EMAIL" ]; then
  echo "BLOCK: No git user.email configured."
  echo "Run: git config --global user.email \"[YOUR_GITHUB_NOREPLY_EMAIL]\""
  exit 2
fi

if echo "$GIT_EMAIL" | grep -qE "\.local$|@localhost"; then
  echo "BLOCK: Git email ($GIT_EMAIL) is a local hostname, not a GitHub email."
  echo "Run: git config --global user.email \"[YOUR_GITHUB_NOREPLY_EMAIL]\""
  exit 2
fi

exit 0
