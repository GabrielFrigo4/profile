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
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "🎨 [Profile] Instalando ecossistema de dotfiles no Windows..." -ForegroundColor Cyan

$SyncScript = Join-Path $ScriptDir "scripts\sync\sync-dotfiles.ps1"
if (Test-Path $SyncScript) {
    & $SyncScript @PSBoundParameters
}

Write-Host "✅ [Profile] Instalação concluída com sucesso no Windows!" -ForegroundColor Green
