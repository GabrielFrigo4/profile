<#
# ----------------------------------------------------------------
# Utility: Universal Profile Windows Installer
# ----------------------------------------------------------------
#>
[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Backup
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Timestamp = (Get-Date).ToString("yyyyMMddHHmmss")

function _ui_step([string]$msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function _ui_sub([string]$msg)  { Write-Host "  ↳ $msg" -ForegroundColor Blue }
function _ui_ok([string]$msg)   { Write-Host "  ✅ $msg" -ForegroundColor Green }
function _ui_warn([string]$msg) { Write-Host "  ⚠️  $msg" -ForegroundColor Yellow }
function _ui_err([string]$msg)  { Write-Host "  ❌ $msg" -ForegroundColor Red }
function _ui_info([string]$msg) { Write-Host "  ℹ️  $msg" -ForegroundColor Magenta }

_ui_step "Sincronizando dotfiles no Windows a partir de: $RepoRoot"
if ($DryRun) {
    _ui_warn "Modo DRY-RUN ativado (nenhum link sera criado)."
}

function Link-Item-Safe {
    param(
        [string]$Source,
        [string]$Destination
    )

    if (-not (Test-Path $Source)) { return }

    if ($DryRun) {
        _ui_sub "[DRY-RUN] $Destination -> $Source"
        return
    }

    $ParentDir = Split-Path -Parent $Destination
    if (-not (Test-Path $ParentDir)) {
        New-Item -ItemType Directory -Path $ParentDir -Force | Out-Null
    }

    $isDir = (Get-Item $Source) -is [System.IO.DirectoryInfo]

    if (Test-Path $Destination) {
        $destItem = Get-Item $Destination -Force
        if ($destItem.LinkType -and ($destItem.Target -eq $Source -or $destItem.Target -contains $Source)) {
            _ui_sub "[OK] $Destination"
            return
        }
        if ($Backup) {
            $BackupPath = "$Destination.bak.$Timestamp"
            Move-Item -Path $Destination -Destination $BackupPath -Force
            _ui_warn "[BACKUP] $BackupPath"
        } else {
            Remove-Item -Path $Destination -Force -Recurse
        }
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Destination -Target $Source -Force | Out-Null
        _ui_ok "[LINK] $Destination"
        return
    } catch {
        if ($isDir) {
            try {
                New-Item -ItemType Junction -Path $Destination -Target $Source -Force | Out-Null
                _ui_ok "[JUNCTION] $Destination"
                return
            } catch { }
        } else {
            try {
                New-Item -ItemType HardLink -Path $Destination -Target $Source -Force | Out-Null
                _ui_ok "[HARDLINK] $Destination"
                return
            } catch { }
        }

        try {
            Copy-Item -Path $Source -Destination $Destination -Recurse -Force | Out-Null
            _ui_warn "[COPY] $Destination (Symlinks restritos pelo SO)"
        } catch {
            _ui_err "[FAIL] $Destination ($_)"
        }
    }
}

_ui_step "Formatadores globais e linters..."
Link-Item-Safe "$RepoRoot\tools\.clang-format" "$HOME\.clang-format"
Link-Item-Safe "$RepoRoot\tools\.prettierrc" "$HOME\.prettierrc"
Link-Item-Safe "$RepoRoot\tools\.stylua.toml" "$HOME\.stylua.toml"
Link-Item-Safe "$RepoRoot\tools\.editorconfig" "$HOME\.editorconfig"
Link-Item-Safe "$RepoRoot\tools\mermaid-puppeteer.json" "$HOME\.mermaid-puppeteer-config.json"
Link-Item-Safe "$RepoRoot\tools\mermaid-theme.json" "$HOME\.mermaid-theme-config.json"
if ($env:LOCALAPPDATA) {
    Link-Item-Safe "$RepoRoot\tools\clangd.yaml" "$env:LOCALAPPDATA\clangd\config.yaml"
}

_ui_step "Editores modernos (VS Code, VSCodium, Antigravity, Zed)..."
if ($env:APPDATA) {
    Link-Item-Safe "$RepoRoot\editors\vscode\settings.json" "$env:APPDATA\Code\User\settings.json"
    Link-Item-Safe "$RepoRoot\editors\vscodium\settings.json" "$env:APPDATA\VSCodium\User\settings.json"
    Link-Item-Safe "$RepoRoot\editors\antigravity\settings.json" "$env:APPDATA\Antigravity\User\settings.json"
    Link-Item-Safe "$RepoRoot\editors\zed\settings.json" "$env:APPDATA\Zed\settings.json"
}

_ui_step "Windows Terminal..."
if ($env:LOCALAPPDATA) {
    $WtPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    Link-Item-Safe "$RepoRoot\terminals\windows-terminal\settings.json" $WtPath
}

_ui_step "Clink (CMD)..."
if ($env:LOCALAPPDATA) {
    $ClinkDir = "$env:LOCALAPPDATA\clink"
    Link-Item-Safe "$RepoRoot\terminals\cmd\profile.lua" "$ClinkDir\profile.lua"
    Link-Item-Safe "$RepoRoot\terminals\cmd\profile.cmd" "$ClinkDir\profile.cmd"
}
Link-Item-Safe "$RepoRoot\terminals\cmd\profile.cmd" "$HOME\profile.cmd"

_ui_step "PowerShell Profiles..."
$PsDocs = "$HOME\Documents\PowerShell"
$WinPsDocs = "$HOME\Documents\WindowsPowerShell"
Link-Item-Safe "$RepoRoot\terminals\powershell\profile.ps1" "$PsDocs\profile.ps1"
Link-Item-Safe "$RepoRoot\terminals\powershell\Microsoft.PowerShell_profile.ps1" "$PsDocs\Microsoft.PowerShell_profile.ps1"
Link-Item-Safe "$RepoRoot\terminals\powershell\profile.ps1" "$WinPsDocs\profile.ps1"

_ui_step "NuShell..."
if ($env:APPDATA) {
    $NuDir = "$env:APPDATA\nushell"
    Link-Item-Safe "$RepoRoot\terminals\nushell\config.nu" "$NuDir\config.nu"
    Link-Item-Safe "$RepoRoot\terminals\nushell\env.nu" "$NuDir\env.nu"
}

_ui_step "Skills portáteis de IA (Antigravity & Gemini)..."
Link-Item-Safe "$RepoRoot\skills" "$HOME\.gemini\config\skills"

_ui_ok "Instalação e sincronização concluídas com sucesso no Windows!"
