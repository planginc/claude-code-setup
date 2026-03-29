# Claude Code Setup

A shareable Claude Code workflow system with hooks for structured sessions, project tracking, and quality guardrails.

## What this gives you

- **Session start**: Claude automatically asks which project you're working on, retrieves last session notes, and presents your backlog before touching any code.
- **Session end**: Saying "end conversation" triggers a mandatory checklist — struggle scan, note saving, HANDOVER.md write, and CLAUDE.md sync.
- **Em dash scanner**: Blocks em dashes from appearing in public-facing HTML (they signal AI-written text).
- **Git email check**: Prevents Vercel deployment failures from misconfigured git emails.
- **New project setup**: When you create a new project folder, Claude is blocked until it sets up README.md, CLAUDE.md, HANDOVER.md, and git.
- **CLAUDE.md sync reminder**: When you edit your global CLAUDE.md, Claude is blocked until it syncs the change to desktop instructions.

## Installation

### 1. Clone the repo

```bash
git clone https://github.com/YOUR_USERNAME/claude-code-setup.git ~/Documents/claude-code-setup
```

### 2. Copy hooks to your Claude folder

```bash
cp ~/Documents/claude-code-setup/hooks/*.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh
```

### 3. Customize session-start.sh

Open `~/.claude/hooks/session-start.sh` and replace the placeholder paths and project IDs with your own projects. See comments inside the file.

### 4. Customize CLAUDE.md

Copy the template and fill in your details:

```bash
cp ~/Documents/claude-code-setup/CLAUDE.md.template ~/.claude/CLAUDE.md
```

Edit it to replace all `[PLACEHOLDER]` values.

### 5. Apply settings.json

Merge the hooks config from `settings.json.example` into your existing `~/.claude/settings.json`. Do not overwrite your whole settings file -- just add the `hooks` block.

### 6. Test it

Start a new Claude Code session from your home directory (`~`). You should see the project picker immediately.

## Files in this repo

```
hooks/
  session-start.sh           -- Project picker + session retrieval
  end-session-checklist.sh   -- Stop hook: fires when agent loop ends
  end-session-trigger.sh     -- UserPromptSubmit hook: intercepts "end conversation"
  em-dash-scanner.sh         -- PostToolUse: blocks em dashes in HTML
  git-email-check.sh         -- PreToolUse: verifies git email before push
  new-project-setup.sh       -- PostToolUse: enforces project setup on new folders
  claude-md-sync-reminder.sh -- PostToolUse: reminds to sync CLAUDE.md changes

CLAUDE.md.template           -- Global instructions template for Claude
settings.json.example        -- Hooks configuration template
IMPROVEMENTS.md              -- What is being built next
```

## Customization notes

- `session-start.sh` is the most personal file. It maps your folder paths to project names. Every path in it is yours to define.
- `CLAUDE.md.template` has `[PLACEHOLDER]` markers for your name, database URLs, and project IDs. Fill these in before using it.
- The end-session hooks mention Convex as the note storage system. If you use a different backend, edit the checklist text in both `end-session-checklist.sh` and `end-session-trigger.sh`.

## See also

- [IMPROVEMENTS.md](IMPROVEMENTS.md) for what is being built next
