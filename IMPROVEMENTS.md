# Improvements In Progress

This file tracks what is being actively built in the Claude Code workflow system. Check back for updates.

---

## What is already built and working

- **Session start project picker** -- Unknown directory triggers a numbered project list. Claude waits for a pick, then retrieves last session notes and HANDOVER.md before doing anything.
- **End session checklist** -- "end conversation" is intercepted before Claude responds. Mandatory 6-step checklist: struggle scan, session note, work log, HANDOVER.md, CLAUDE.md sync, confirm close.
- **Stop hook fallback** -- If the agent loop ends without "end conversation" being said, the Stop hook fires a second check to catch missed sessions.
- **HANDOVER.md protocol** -- Every project has a `HANDOVER.md` that gets overwritten each session. It carries forward unresolved items and captures what changed, what failed, and what is next.
- **Em dash scanner** -- PostToolUse hook scans HTML files after every edit. Exits 2 (blocks) if U+2014 is found. Em dashes signal AI-written text and are banned from public-facing content.
- **Git email check** -- Verifies git user.email is set to a GitHub-recognized address before any push. Prevents Vercel deployment blocks.
- **New project setup enforcement** -- Creating a top-level project folder triggers a checklist: git init, CLAUDE.md, README.md, HANDOVER.md, initial commit, add to session-start map.
- **CLAUDE.md sync reminder** -- Editing the global CLAUDE.md blocks Claude until it surfaces exactly what changed and confirms the sync to any secondary instruction surfaces (Desktop, etc.).
- **Auto-memory system** -- Persistent file-based memory at `~/.claude/projects/.../memory/`. Stores user profile, feedback, project context, and references across conversations.
- **Context compression warning** -- CLAUDE.md rule: Claude must warn before the conversation compresses and refuse to continue after one compression. Protects token quota.

---

## In progress / planned

### 1. Session picker improvements
- The project list in `session-start.sh` is hardcoded. Goal: auto-generate from a config file so adding a project only requires one edit.
- Add a "no project / general question" option (#0) for non-project sessions.

### 2. Smarter HANDOVER.md diffs
- Currently HANDOVER.md is fully overwritten each session. Goal: detect carry-forward items that have been silently dropped and surface them as warnings before overwriting.

### 3. Hook health check command
- A single `/hook-status` command that verifies all hooks are executable, wired in settings.json, and have passed their last run. Right now there is no visibility into whether hooks are silently failing.

### 4. Cross-surface instruction sync automation
- Desktop/Cowork instructions require a manual copy-paste today. Goal: a script that diffs CLAUDE.md against desktop-instructions.md and outputs only the changes needed, not a full rewrite.

### 5. Session note deduplication guard
- Claude sometimes creates a new session note when one already exists for that session. Goal: a pre-write check that queries for an existing note with the same title prefix before inserting.

### 6. Backlog surfacing improvements
- The session start currently shows all backlog items regardless of status. Goal: filter to `pending` tasks only, group by priority, and show the top 3 rather than the full list.

---

## Contributing

If you build any of these, open a PR or file an issue. The goal is a workflow that any Claude Code user can install and adapt without deep technical setup.
