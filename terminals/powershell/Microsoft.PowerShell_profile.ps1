<#
# ----------------------------------------------------------------
# Module: PowerShell Visual Appearance Configuration
# ----------------------------------------------------------------
#>

if ($Host.Name -eq 'ConsoleHost') {
	Import-Module Terminal-Icons
	. "~/.oh-my-posh.ps1";
}
