# Terminal title setter for Claude Code and Codex on Windows.
#
# Usage:
#   set_title.ps1 "Your Title Here"            # arg mode (skill invocation)
#   '{"prompt":"..."}' | set_title.ps1          # stdin mode (UserPromptSubmit hook)
#
# Sets the hosting console's title to "<cwd-name> | <title>". The optional
# environment variable CODEX_TITLE_PREFIX or CLAUDE_TITLE_PREFIX is prepended
# if set. CODEX_TITLE_PREFIX wins when both are present.
#
# Why this script exists alongside set_title.sh: on native Windows agent
# sessions, stdout control bytes can be stripped before display, so the
# printf '\033]0;...\007' approach in the .sh version may never reach the
# host terminal. This script bypasses stdout by calling [Console]::Title,
# which wraps the Win32 SetConsoleTitle API on the inherited console.

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Title
)

if (-not $Title -and [Console]::IsInputRedirected) {
    try {
        $payload = [Console]::In.ReadToEnd() | ConvertFrom-Json -ErrorAction Stop
        $Title = $payload.prompt
    } catch {
        exit 0
    }
}

if (-not $Title) { exit 0 }

$clean = ($Title -replace '[\x00-\x1F]+', ' ' -replace '\s+', ' ').Trim()
if ($clean.Length -gt 60) { $clean = $clean.Substring(0, 60).TrimEnd() + '...' }
if (-not $clean) { exit 0 }

$dir = Split-Path -Leaf (Get-Location).Path
$prefix = if ($env:CODEX_TITLE_PREFIX) { $env:CODEX_TITLE_PREFIX } else { $env:CLAUDE_TITLE_PREFIX }

$final = if ($prefix) { "$prefix | $dir | $clean" } else { "$dir | $clean" }

try { [Console]::Title = $final } catch { }
