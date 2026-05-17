---
name: terminal-title
description: Automatically updates the terminal window title to reflect the current high-level task. Use at the start of every Claude Code or Codex session when the user provides their first prompt, and whenever the user switches to a distinctly new high-level task. Helps developers manage multiple agent terminals by providing clear, at-a-glance identification of what each terminal is doing.
min_claude_code_version: "1.0.0"
version: "1.3.0"
---

# Terminal Title

## Overview

Automatically sets descriptive terminal window titles based on the current task. This is useful when running multiple Claude Code or Codex instances and needing to identify the right terminal quickly.

## When to Use

Always trigger this skill:
- At the start of every new Claude Code or Codex session after receiving the first user prompt.
- When switching to a substantially different task, such as moving from "API Integration" to "Database Migration".

Trigger on task switches like these:
- Switching from frontend work to backend work.
- Moving from debugging to new feature development.
- Changing from one module/component to a completely different one.
- Starting work on a different part of the system, such as auth to payments.

Do not trigger for:
- Follow-up questions about the same task, such as "Can you add a comment to that function?"
- Small refinements to current work, such as "Make it blue instead of red".
- Debugging the same feature you just built.
- Clarifications, status updates, or progress checks.
- Iterating on the same component or module.

## How It Works

1. Extract a concise task summary from the user's prompt.
2. Generate a descriptive title, usually 40 characters or less.
3. Execute the host-appropriate title script with the generated title.
4. Continue silently; no confirmation is needed.

## Title Format Guidelines

Good titles:
- "API Integration: Auth Flow"
- "Fix: Login Bug"
- "DB Migration: Users Table"
- "Build: Dashboard UI"
- "Refactor: Payment Module"

Bad titles:
- Too long: "Implementing the new authentication system with OAuth2.0 support"
- Too generic: "Working" or "Coding"
- Too verbose: "The user wants me to help them with..."

Format pattern:
```
[Action/Category]: [Specific Focus]
```

Keep titles concise, actionable, and immediately recognizable.

## Implementation

On Windows PowerShell, use the PowerShell script. Prefer the installed skill path reported by the current environment. On this Codex install, custom skills live under `.agents\skills`:

```powershell
& "$env:USERPROFILE\.agents\skills\terminal-title\scripts\set_title.ps1" "Your Title Here"
```

If this skill is installed directly under Codex's home directory instead, use:

```powershell
& "$env:USERPROFILE\.codex\skills\terminal-title\scripts\set_title.ps1" "Your Title Here"
```

For Claude Code on Windows, use:

```powershell
& "$env:USERPROFILE\.claude\skills\terminal-title\scripts\set_title.ps1" "Your Title Here"
```

On macOS / Linux, execute the bash script:

```bash
bash scripts/set_title.sh "Your Title Here"
```

Pick the script that matches the host OS. If unsure, the working directory's path style is a reliable hint: `/home/...` or `/Users/...` means POSIX, while `C:\...` or `D:\...` means Windows.

Example workflow on this Codex/PowerShell install:

```powershell
# User asks: "Help me debug the authentication flow in the API"
& "$env:USERPROFILE\.agents\skills\terminal-title\scripts\set_title.ps1" "Debug: Auth API Flow"

# User asks: "Create a React component for the user profile page"
& "$env:USERPROFILE\.agents\skills\terminal-title\scripts\set_title.ps1" "Build: User Profile UI"

# User asks: "Write tests for the payment processing module"
& "$env:USERPROFILE\.agents\skills\terminal-title\scripts\set_title.ps1" "Test: Payment Module"
```

## Script Details

`scripts/set_title.ps1` uses the .NET `[Console]::Title` API, which wraps the Win32 `SetConsoleTitle` API. This works in Windows Terminal, Windows Console Host, and ConPTY-hosted terminals.

The Windows PowerShell script is required for native Windows agent sessions because the bash script's ANSI OSC escape sequence can be stripped from subprocess stdout before it reaches the host terminal. The PowerShell script bypasses stdout by setting the inherited console title directly.

The script accepts a single argument and exits silently if no title is provided. It also accepts JSON via stdin when invoked as a prompt hook, reading the `prompt` field as the title.

`scripts/set_title.sh` uses ANSI OSC escape sequences and stores the last title in `~/.claude/terminal_title` so shell hooks can preserve it across prompts.

## Optional Customization

Users can optionally customize terminal titles with a prefix:

PowerShell:
```powershell
$env:CODEX_TITLE_PREFIX = "Codex"
```

Bash/zsh:
```bash
export CODEX_TITLE_PREFIX="Codex"
```

For Claude Code users, `CLAUDE_TITLE_PREFIX` is still supported. If both variables are set, `CODEX_TITLE_PREFIX` wins.

With a prefix, titles look like:

```text
Codex | project-name | Build: Dashboard UI
```

Without a prefix, titles look like:

```text
project-name | Build: Dashboard UI
```

The script handles these variables automatically.
