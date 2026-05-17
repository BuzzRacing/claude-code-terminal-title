[CmdletBinding()]
param(
    [string]$InstallDir
)

$ErrorActionPreference = 'Stop'

function Write-Step($Message) {
    Write-Host "[terminal-title] $Message"
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$skillFile = Join-Path $scriptDir 'terminal-title.skill'

if (-not (Test-Path -LiteralPath $skillFile)) {
    throw "terminal-title.skill not found at: $skillFile"
}

if (-not $InstallDir) {
    $agentsSkills = Join-Path $env:USERPROFILE '.agents\skills'
    $codexSkills = Join-Path $env:USERPROFILE '.codex\skills'
    $InstallDir = if (Test-Path -LiteralPath $agentsSkills) { $agentsSkills } else { $codexSkills }
}

Write-Step "Installing to $InstallDir"
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

$tempZip = Join-Path ([IO.Path]::GetTempPath()) ("terminal-title-{0}.zip" -f [guid]::NewGuid())
try {
    Copy-Item -LiteralPath $skillFile -Destination $tempZip -Force
    Expand-Archive -LiteralPath $tempZip -DestinationPath $InstallDir -Force
} finally {
    Remove-Item -LiteralPath $tempZip -Force -ErrorAction SilentlyContinue
}

$titleScript = Join-Path $InstallDir 'terminal-title\scripts\set_title.ps1'
if (-not (Test-Path -LiteralPath $titleScript)) {
    throw "Installed package is missing scripts\set_title.ps1"
}

Write-Step "Running smoke test"
& $titleScript 'Test: Codex PowerShell OK'

Write-Step "Installed terminal-title for Codex PowerShell."
Write-Step "Restart Codex so the skill index reloads if this was a fresh install."
