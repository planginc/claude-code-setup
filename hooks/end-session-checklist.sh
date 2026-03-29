#!/bin/bash
# Stop hook: fires when the agent loop ends.
# Reads the session transcript to detect if the user said "end conversation".
# Fully mechanical -- no flag file or instruction-following required.
#
# NOTE: Steps 2-4 reference Convex as the note storage system.
# If you use a different backend, update the text in the cat <<'EOF' block.

INPUT=$(cat)

# Prevent re-firing: if Stop hook already ran this cycle, bail out.
ALREADY_ACTIVE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print('yes' if d.get('stop_hook_active') else 'no')" 2>/dev/null || echo "no")
if [ "$ALREADY_ACTIVE" = "yes" ]; then
  exit 0
fi

TRANSCRIPT=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('transcript_path',''))" 2>/dev/null || echo "")

if [ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ]; then
  exit 0
fi

FOUND=$(python3 << PYEOF
import json, sys

transcript_path = "$TRANSCRIPT"
try:
    with open(transcript_path, 'r') as f:
        lines = f.readlines()

    user_msgs = []
    for line in lines:
        try:
            entry = json.loads(line)
            if entry.get('type') == 'user':
                content = entry.get('message', {}).get('content', '')
                if isinstance(content, str):
                    user_msgs.append(content.lower())
                elif isinstance(content, list):
                    for block in content:
                        if isinstance(block, dict) and block.get('type') == 'text':
                            user_msgs.append(block.get('text', '').lower())
        except:
            pass

    for msg in user_msgs[-5:]:
        if 'end conversation' in msg:
            print('yes')
            sys.exit(0)
    print('no')
except:
    print('no')
PYEOF
)

if [ "$FOUND" = "yes" ]; then
  cat <<'EOF'
[BLOCKED] Session cannot close. Required steps not complete.
You must work through all steps below before this session ends. Do not summarize. Do not sign off. Do not say the session is ending. Start Step 0 now or the session record will be incomplete.

Step 0: Struggle scan (always first)
  Review the full conversation for: errors requiring retries, user corrections,
  failed commands, backtracking, CLAUDE.md rules needed but not followed.
  Save each distinct struggle as a troubleshooting or technical_solution note
  in your note storage, linked to the project. Title: [Session] <short description>.

Step 1: Query project status for the active project. Confirm project ID with the user.

Step 2: Update or create the session note in your note storage. ADD to existing, never replace. Link to project.

Step 3: Append work log to project status.
  Use this format:
    PROJECT UPDATE: [Project Name]
    - Status: [Planning/Active/Paused/Waiting/Completed]
    - What accomplished: [specifics]
    - Current Working State: [what is functional now]
    - Technical details: [key implementation notes]
    - Next single step: [one actionable task]
    - Blockers: [if any]
    - Troubleshooting Summary: [problems, solutions, error messages, components]
    - Referenced Notes: Note #XXX - [Title]

Step 4: Write HANDOVER.md in the project folder.
  FIRST: read the existing HANDOVER.md if it exists. Preserve any "Carry forward" section items
  that are not yet resolved. Only clear a carry-forward item if it was explicitly completed this session.
  THEN overwrite the rest of the file with:
  - Carry forward: unresolved items from prior session (preserved or updated, never silently dropped)
  - What changed this session (specific files, specific config changes)
  - What was tried and did not work (so next session does not repeat mistakes)
  - What is next (the single next step, not a wishlist)
  - Key decisions made and why
  CLAUDE.md is for permanent rules only. Do NOT add session state to CLAUDE.md.
  If no project folder is known, ask for the path before writing.

Step 5: Global CLAUDE.md sync.
  If ~/.claude/CLAUDE.md was changed this session:
  - Confirm the change was synced to any secondary instruction surfaces (e.g., Desktop custom instructions).
  - Wait for the user to confirm before making any edit to secondary surfaces.
  - Only after confirmation: make the surgical change.
  Never skip the confirmation wait. Do not edit secondary surfaces without explicit approval.

Step 6: Tell the user all steps are complete and the session is ready to close.

Do not stop until all six steps are confirmed done.
EOF
  exit 2
fi

exit 0
