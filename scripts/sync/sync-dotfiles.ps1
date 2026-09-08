<#
# ----------------------------------------------------------------
# Utility: Profile Dotfiles Windows Synchronizer
# ----------------------------------------------------------------
#>
[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Backup
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$Timestamp = (Get-Date).ToString("yyyyMMddHHmmss")

Write-Host "🎨 [Profile] Sincronizando dotfiles no Windows a partir de: $RepoRoot" -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "  ⚠️ Modo DRY-RUN ativado (nenhum link sera criado)." -ForegroundColor Yellow
}

function Link-File {
    param(
        [string]$Source,
        [string]$Destination
    )

    if (-not (Test-Path $Source)) { return }

    if ($DryRun) {
        Write-Host "  [DRY-RUN] $Destination -> $Source" -ForegroundColor DarkGray
        return
    }

    $ParentDir = Split-Path -Parent $Destination
    if (-not (Test-Path $ParentDir)) {
        New-Item -ItemType Directory -Path $ParentDir -Force | Out-Null
    }

    if (Test-Path $Destination) {
        if ($Backup) {
            $BackupPath = "$Destination.bak.$Timestamp"
            Move-Item -Path $Destination -Destination $BackupPath -Force
            Write-Host "  [BACKUP] $BackupPath" -ForegroundColor Magenta
        } else {
            Remove-Item -Path $Destination -Force -Recurse
        }
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Destination -Target $Source -Force | Out-Null
        Write-Host "  [LINK] $Destination" -ForegroundColor Green
    } catch {
        New-Item -ItemType HardLink -Path $Destination -Target $Source -Force | Out-Null
        Write-Host "  [HARDLINK] $Destination" -ForegroundColor Yellow
    }
}

Write-Host "↳ 1. Formatadores globais e linters..." -ForegroundColor Cyan
Link-File "$RepoRoot\software\tools\.clang-format" "$HOME\.clang-format"
Link-File "$RepoRoot\software\tools\.prettierrc" "$HOME\.prettierrc"
Link-File "$RepoRoot\software\tools\.stylua.toml" "$HOME\.stylua.toml"
Link-File "$RepoRoot\software\tools\.editorconfig" "$HOME\.editorconfig"

Write-Host "↳ 2. Editores modernos (VS Code & Antigravity)..." -ForegroundColor Cyan
if ($env:APPDATA) {
    Link-File "$RepoRoot\software\editors\vscode\settings.json" "$env:APPDATA\Code\User\settings.json"
    Link-File "$RepoRoot\software\editors\antigravity\settings.json" "$env:APPDATA\Antigravity\User\settings.json"
}

Write-Host "↳ 3. Windows Terminal..." -ForegroundColor Cyan
$WtPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
Link-File "$RepoRoot\software\terminals\windows-terminal\settings.json" $WtPath

Write-Host "↳ 4. Clink (CMD)..." -ForegroundColor Cyan
$ClinkDir = "$env:LOCALAPPDATA\clink"
Link-File "$RepoRoot\software\terminals\cmd\profile.lua" "$ClinkDir\profile.lua"
Link-File "$RepoRoot\software\terminals\cmd\profile.cmd" "$ClinkDir\profile.cmd"

Write-Host "↳ 5. PowerShell Profiles..." -ForegroundColor Cyan
$PsDocs = "$HOME\Documents\PowerShell"
$WinPsDocs = "$HOME\Documents\WindowsPowerShell"
Link-File "$RepoRoot\software\terminals\powershell\profile.ps1" "$PsDocs\profile.ps1"
Link-File "$RepoRoot\software\terminals\powershell\Microsoft.PowerShell_profile.ps1" "$PsDocs\Microsoft.PowerShell_profile.ps1"
Link-File "$RepoRoot\software\terminals\powershell\profile.ps1" "$WinPsDocs\profile.ps1"

Write-Host "↳ 6. NuShell..." -ForegroundColor Cyan
if ($env:APPDATA) {
    $NuDir = "$env:APPDATA\nushell"
    Link-File "$RepoRoot\software\terminals\nushell\config.nu" "$NuDir\config.nu"
    Link-File "$RepoRoot\software\terminals\nushell\env.nu" "$NuDir\env.nu"
    Link-File "$RepoRoot\software\terminals\nushell\nushell.nu" "$NuDir\nushell.nu"
}

Write-Host "✅ [Profile] Sincronizacao concluida com sucesso no Windows!" -ForegroundColor Green
