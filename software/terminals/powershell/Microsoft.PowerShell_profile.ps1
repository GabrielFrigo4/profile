### APARÊNCIA E INTERATIVIDADE

if ($Host.Name -eq 'ConsoleHost') {
	# Terminal Icons
	Import-Module Terminal-Icons

	# "In PowerShell"
	# oh-my-posh init pwsh --config "${HOME}/.oh-my-posh/themes/atomic.omp.json" > "${HOME}/.oh-my-posh.ps1"
	. "~/.oh-my-posh.ps1";
}
