<#
# ----------------------------------------------------------------
# Module: PowerShell Visual Appearance Configuration
# ----------------------------------------------------------------
#>

if ($Host.Name -eq 'ConsoleHost') {
	if (Get-Module -ListAvailable -Name Terminal-Icons) {
		Import-Module Terminal-Icons
	}
	if (Test-Path "~/.oh-my-posh.ps1") {
		. "~/.oh-my-posh.ps1"
	}
}
