<#
# ----------------------------------------------------------------
# Module: PowerShell Interactive Environment Profile
# ----------------------------------------------------------------
#>

### ================================
### CONFIGURACOES GERAIS
### ================================

$PSDefaultparameterValues['*:Encoding'] = 'utf8'

$env:HOME = $env:USERPROFILE
$SYSTEM32 = 'C:\Windows\System32'

function Get-Msys2UserHome {
	$root     = if ($env:MSYS2_ROOT) { $env:MSYS2_ROOT } else { 'C:\msys64' }
	$homeBase = if ($env:MSYS2_HOME) { $env:MSYS2_HOME } else { Join-Path $root 'home' }
	$user     = if ($env:MSYS2_USER) { $env:MSYS2_USER } else { $env:USERNAME }

	$target = Join-Path $homeBase $user
	if (-not (Test-Path $target)) {
		$target = Join-Path $homeBase $user.ToLower()
	}
	if (Test-Path $target) { return $target }
	return $null
}

$MsysHome = Get-Msys2UserHome

$vaultCandidates = @(
	$env:VAULT_DIR,
	(Join-Path $HOME ".local\share\vault"),
	(Join-Path $HOME ".config\vault"),
	(Join-Path $HOME ".vault")
)
if ($MsysHome) {
	$vaultCandidates += @(
		(Join-Path $MsysHome ".local\share\vault"),
		(Join-Path $MsysHome ".config\vault"),
		(Join-Path $MsysHome ".vault")
	)
}

$vaultDir = $vaultCandidates | Where-Object { $_ -and (Test-Path (Join-Path $_ "vault.ps1")) } | Select-Object -First 1

if ($vaultDir) {
	. (Join-Path $vaultDir "vault.ps1")
}

$OneDrive  = "${Home}\onedrive"
$Desktop   = "${OneDrive}\Área de Trabalho"
$Documents = "${OneDrive}\Documentos"
$Images    = "${OneDrive}\Imagens"
$Workspace = "${OneDrive}\Workspace"
$Downloads = "${Home}\Downloads"

$VIRTUAL_STORE = "$($env:LOCALAPPDATA)\VirtualStore"
$FASM_STORE    = "${VIRTUAL_STORE}\Program Files\FASM"
$FASM2_STORE   = "${VIRTUAL_STORE}\Program Files\FASM2"
$FASMG_STORE   = "${VIRTUAL_STORE}\Program Files\FASMG"
$FASMARM_STORE = "${VIRTUAL_STORE}\Program Files\FASMARM"

$IsAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
$Machine = [Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::Machine)
$User    = [Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::User)

### ================================
### NAVEGACAO E EDICAO
### ================================

function Edit-Profile-Logic { notepad++ "${Home}\OneDrive\Documentos\PowerShell\profile.ps1" }
function Edit-Profile-Visual { notepad++ "${Home}\OneDrive\Documentos\PowerShell\Microsoft.PowerShell_profile.ps1" }

function Goto-User { Set-Location -Path "${Home}" }
function Goto-OneDrive { Set-Location -Path "${OneDrive}" }
function Goto-Desktop { Set-Location -Path "${Desktop}" }
function Goto-Documents { Set-Location -Path "${Documents}" }
function Goto-Workspace { Set-Location -Path "${Workspace}" }
function Goto-Images { Set-Location -Path "${Images}" }
function Goto-Downloads { Set-Location -Path "${Downloads}" }
function Goto-Virtual-Store { Set-Location -Path "${VIRTUAL_STORE}" }
function Goto-FASM-Store { Set-Location -Path "${FASM_STORE}" }
function Goto-Machine { Set-Location -Path "$SYSTEM32" }
function Goto-Msys { Set-Location -Path (if ($MsysHome) { $MsysHome } else { 'C:\msys64' }) }

function Show-Explorer { explorer.exe . }
function Show-User { explorer.exe "${Home}" }
function Show-OneDrive { explorer.exe "${OneDrive}" }
function Show-Desktop { explorer.exe "${Desktop}" }
function Show-Documents { explorer.exe "${Documents}" }
function Show-Workspace { explorer.exe "${Workspace}" }
function Show-Images { explorer.exe "${Images}" }
function Show-Downloads { explorer.exe "${Downloads}" }
function Show-Virtual-Store { explorer.exe "${VIRTUAL_STORE}" }
function Show-FASM-Store { explorer.exe "${FASM_STORE}" }
function Show-Machine { explorer.exe "$SYSTEM32" }
function Show-Msys { explorer.exe (if ($MsysHome) { $MsysHome } else { 'C:\msys64' }) }

### ================================
### SISTEMA E ADMINISTRACAO
### ================================

function Start-Admin {
	param(
		[parameter(Mandatory=$true, Position=0)][string] $Name,
		[parameter(Mandatory=$false, ValueFromRemainingArguments=$true)][string[]] $Args,
		[parameter(Mandatory=$false)][string] $WindowStyle = "Normal",
		[parameter(Mandatory=$false)][switch] $NoNewWindow,
		[parameter(Mandatory=$false)][switch] $PassThru
	)

	if ($NoNewWindow -and $IsAdmin) {
		$process = Start-Process -FilePath $Name -ArgumentList $Args -NoNewWindow:$NoNewWindow -PassThru:$PassThru
	}
	elseif ($IsAdmin) {
		$process = Start-Process -FilePath $Name -ArgumentList $Args -WindowStyle $WindowStyle -PassThru:$PassThru
	}
	else {
		$process = Start-Process -FilePath $Name -ArgumentList $Args -Verb runAs -WindowStyle $WindowStyle -PassThru:$PassThru
	}
	return $process
}

function Start-Windows-Terminal-Admin {
	param([parameter(Mandatory=$true, Position=0)][string] $Name, [parameter(ValueFromRemainingArguments=$true)][string[]] $Args)
	$Args = $Name + " " + $Args
	Start-Admin -Name "wt.exe" -Args $Args
}

function Start-Console-Host-Admin {
	param([parameter(Mandatory=$true, Position=0)][string] $Name, [parameter(ValueFromRemainingArguments=$true)][string[]] $Args)
	$Args = $Name + " " + $Args
	Start-Admin -Name "conhost.exe" -Args $Args
}

### ================================
### AMBIENTE E VARIAVEIS
### ================================

function Setx-User {
	param(
		[Parameter(Mandatory=$true)] [string]$Name,
		[Parameter(Mandatory=$true)] [string]$Value
	)
	[Environment]::SetEnvironmentVariable($Name, $Value, [System.EnvironmentVariableTarget]::User)
	Set-Item -Path "env:$Name" -Value $Value

	Write-Host "Variável '$Name' definida como '$Value' (User Scope)" -ForegroundColor Cyan
}

function Setx-Machine {
	param(
		[Parameter(Mandatory=$true)] [string]$Name,
		[Parameter(Mandatory=$true)] [string]$Value
	)
	$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

	if ($IsAdmin) {
		[Environment]::SetEnvironmentVariable($Name, $Value, [System.EnvironmentVariableTarget]::Machine)
		Set-Item -Path "env:$Name" -Value $Value

		Write-Host "Variável '$Name' definida como '$Value' (Machine Scope)" -ForegroundColor Red
	} else {
		Write-Warning "Você precisa executar como Administrador para definir variáveis de sistema (Machine)."
	}
}

function Getx-User {
	param([string]$Name)
	$val = Get-Content "env:$Name" -ErrorAction SilentlyContinue
	if (-not $val) {
		$val = [Environment]::GetEnvironmentVariable($Name, [System.EnvironmentVariableTarget]::User)
	}
	return $val
}

function Getx-Machine {
	param([string]$Name)
	[Environment]::GetEnvironmentVariable($Name, [System.EnvironmentVariableTarget]::Machine)
}

function Get-VM-IPs {
	Get-VM | Where-Object {$_.State -eq "Running"} | ForEach-Object {
		$vm = $_
		$vm.NetworkAdapters | Select-Object @{N='VMName';E={$vm.VMName}}, MacAddress, SwitchName, IPAddresses
	}
}

function Get-IP {
	param([switch]$all)
	if ($all) {
		Get-NetIPConfiguration -Detailed
	} else {
		Get-NetIPConfiguration | Select-Object InterfaceAlias, IPv4Address, IPv6LinkLocalAddress, DNSServer
	}
}

### ================================
### FERRAMENTAS
### ================================

function Browser-Search {
	param([parameter(ValueFromRemainingArguments=$true)][string[]] $Args)
	lynx -use_mouse=on -nobrowse=on -nopause=on -show_cursor=off $Args
}

### ================================
### EMISSAO E UI SEMANTICA
### ================================

function _ui_step([string]$msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function _ui_sub([string]$msg)  { Write-Host "  ↳ $msg" -ForegroundColor Blue }
function _ui_ok([string]$msg)   { Write-Host "  ✅ $msg" -ForegroundColor Green }
function _ui_warn([string]$msg) { Write-Host "  ⚠️  $msg" -ForegroundColor Yellow }
function _ui_err([string]$msg)  { [Console]::Error.WriteLine("  ❌ $msg") }
function _ui_info([string]$msg) { Write-Host "  ℹ️  $msg" -ForegroundColor Magenta }
function _ui_banner([string]$title) {
	$sep = "=" * 64
	Write-Host ""
	Write-Host $sep -ForegroundColor Cyan
	Write-Host "  $title" -ForegroundColor White
	Write-Host $sep -ForegroundColor Cyan
	Write-Host ""
}

### ================================
### ATUALIZACAO
### ================================

function Update-Winget {
	_ui_step "Atualizando pacotes via Winget..."
	winget upgrade --all
	if ($LASTEXITCODE -eq 0) { _ui_ok "Winget atualizado com sucesso!" }
}

function Update-Scoop {
	_ui_step "Atualizando pacotes via Scoop..."
	scoop update
	scoop update --all
	_ui_ok "Scoop atualizado com sucesso!"
}

function Update-Choco {
	_ui_step "Atualizando pacotes via Chocolatey..."
	$process = Start-Process -FilePath "choco" -ArgumentList "upgrade all -y" -Verb RunAs -PassThru -WindowStyle Normal
	Wait-Process -InputObject $process
	_ui_ok "Chocolatey atualizado com sucesso!"
}

function Update-Windows {
	_ui_step "Executando Windows Update com reinicialização automática se necessário..."
	$cmd = "Get-WindowsUpdate -AcceptAll -Install -AutoReboot"
	$process = Start-Process -FilePath "pwsh" -ArgumentList "-Command $cmd" -Verb RunAs -PassThru -WindowStyle Normal
	Wait-Process -InputObject $process
	_ui_ok "Windows Update finalizado!"
}

function Update-Git {
	param(
		[parameter(Position=0, Mandatory=$false)][string] $Path = "."
	)
	$targetPath = if ($Path) { (Resolve-Path $Path).Path } else { (Get-Location).Path }
	if (-not (Test-Path $targetPath)) {
		_ui_err "Diretório não encontrado: $targetPath"
		return
	}

	_ui_step "Buscando e atualizando repositórios Git em: $targetPath"
	Write-Host ""

	$gitDirs = Get-ChildItem -Path $targetPath -Directory -Recurse -Depth 3 -Force -Filter ".git" -ErrorAction SilentlyContinue
	if (-not $gitDirs) {
		_ui_info "Nenhum repositório Git encontrado em $targetPath (profundidade máxima: 3)."
		return
	}

	foreach ($gitDir in $gitDirs) {
		$repoDir = $gitDir.Parent.FullName
		_ui_sub "Atualizando $repoDir..."
		git -C $repoDir pull --ff-only 2>$null
		if ($LASTEXITCODE -ne 0) {
			git -C $repoDir pull
		}
	}
	Write-Host ""
	_ui_ok "Varredura e atualização de repositórios Git concluída!"
}

function Update-Editors {
	_ui_step "Atualizando a Suíte de Editores no Windows..."
	$found = 0

	$emacsPath = Join-Path $HOME ".emacs.d"
	if (-not (Test-Path $emacsPath) -and $env:APPDATA) {
		$emacsPath = Join-Path $env:APPDATA ".emacs.d"
	}
	if (Test-Path (Join-Path $emacsPath ".git")) {
		$found = 1
		_ui_sub "Atualizando Emacs em $emacsPath..."
		git -C $emacsPath pull --ff-only
		if (Test-Path (Join-Path $emacsPath ".gitmodules")) {
			_ui_sub "Sincronizando submódulos Elisp..."
			git -C $emacsPath submodule update --init --recursive --remote --merge
		}
		_ui_ok "Emacs atualizado com sucesso!"
	}

	$helixPath = if ($env:APPDATA) { Join-Path $env:APPDATA "helix" } else { Join-Path $HOME ".config\helix" }
	if (-not (Test-Path (Join-Path $helixPath ".git")) -and (Test-Path (Join-Path $HOME ".config\helix\.git"))) {
		$helixPath = Join-Path $HOME ".config\helix"
	}
	if (Test-Path (Join-Path $helixPath ".git")) {
		$found = 1
		_ui_sub "Atualizando Helix em $helixPath..."
		git -C $helixPath pull --ff-only
		_ui_ok "Helix atualizado com sucesso!"
	}

	$nvimPath = if ($env:LOCALAPPDATA) { Join-Path $env:LOCALAPPDATA "nvim" } else { Join-Path $HOME ".config\nvim" }
	if (-not (Test-Path (Join-Path $nvimPath ".git")) -and (Test-Path (Join-Path $HOME ".config\nvim\.git"))) {
		$nvimPath = Join-Path $HOME ".config\nvim"
	}
	if (Test-Path (Join-Path $nvimPath ".git")) {
		$found = 1
		_ui_sub "Atualizando NeoVim em $nvimPath..."
		git -C $nvimPath pull --ff-only
		_ui_ok "NeoVim atualizado com sucesso!"
	}

	$vimPath = Join-Path $HOME "vimfiles"
	if (-not (Test-Path (Join-Path $vimPath ".git")) -and (Test-Path (Join-Path $HOME ".vim\.git"))) {
		$vimPath = Join-Path $HOME ".vim"
	}
	if (Test-Path (Join-Path $vimPath ".git")) {
		$found = 1
		_ui_sub "Atualizando Vim em $vimPath..."
		git -C $vimPath pull --ff-only
		_ui_ok "Vim atualizado com sucesso!"
	}

	if ($found -eq 0) {
		_ui_info "Nenhum repositório de editor encontrado nos caminhos canônicos (~/.emacs.d, helix, nvim, vimfiles)."
	} else {
		_ui_ok "Suíte de Editores sincronizada com sucesso!"
	}
}

function Update-Profile {
	$candidates = @(
		$env:PROFILE_DIR,
		(Join-Path $HOME ".local\share\profile"),
		(Join-Path $HOME ".config\profile"),
		(Join-Path $HOME ".profile"),
		(Join-Path $HOME "OneDrive\Documentos\Profile"),
		(Join-Path $HOME "Documents\Profile")
	)
	if ($MsysHome) {
		$candidates += @(
			(Join-Path $MsysHome ".local\share\profile"),
			(Join-Path $MsysHome ".config\profile"),
			(Join-Path $MsysHome ".profile")
		)
	}
	$target = $candidates | Where-Object { $_ -and (Test-Path (Join-Path $_ ".git")) } | Select-Object -First 1

	if ($target) {
		_ui_step "Atualizando Universal Profile em: $target..."
		git -C $target pull --ff-only
		$installer = Join-Path $target "install.ps1"
		if (Test-Path $installer) {
			_ui_sub "Sincronizando dotfiles e links via install.ps1..."
			& $installer
		}
		_ui_ok "Universal Profile atualizado e sincronizado com sucesso!"
	} else {
		_ui_info "Repositório do Profile não encontrado."
	}
}

function Update-Vault {
	$candidates = @(
		$env:VAULT_DIR,
		(Join-Path $HOME ".local\share\vault"),
		(Join-Path $HOME ".config\vault"),
		(Join-Path $HOME ".vault")
	)
	if ($MsysHome) {
		$candidates += @(
			(Join-Path $MsysHome ".local\share\vault"),
			(Join-Path $MsysHome ".config\vault"),
			(Join-Path $MsysHome ".vault")
		)
	}
	$target = $candidates | Where-Object { $_ -and (Test-Path (Join-Path $_ ".git")) } | Select-Object -First 1

	if ($target) {
		_ui_step "Atualizando Universal Vault em: $target..."
		git -C $target pull --ff-only
		_ui_ok "Universal Vault atualizado com sucesso!"
	} else {
		_ui_info "Repositório do Vault não encontrado."
	}
}

function Update-Shell {
	$candidates = @(
		$env:SHELL_REPO_DIR,
		(Join-Path $HOME ".local\share\shell"),
		(Join-Path $HOME ".config\shell"),
		(Join-Path $HOME ".shell"),
		"C:\Program Files\Shell"
	)
	if ($MsysHome) {
		$candidates += @(
			(Join-Path $MsysHome ".local\share\shell"),
			(Join-Path $MsysHome ".config\shell"),
			(Join-Path $MsysHome ".shell")
		)
	}
	$target = $candidates | Where-Object { $_ -and (Test-Path (Join-Path $_ ".git")) } | Select-Object -First 1

	if ($target) {
		_ui_step "Atualizando Universal Shell em: $target..."
		git -C $target pull --ff-only
		_ui_ok "Universal Shell atualizado com sucesso!"
	} else {
		_ui_info "Repositório do Shell não encontrado."
	}
}

function Update-System {
	_ui_step "Atualizando gerenciadores de pacotes do sistema..."
	Update-Winget
	Update-Scoop
	Update-Choco
	_ui_ok "Atualização de pacotes do sistema concluída!"
}

function Update-All {
	_ui_banner "Atualização Global do Ecossistema e Sistema"
	Update-System
	Update-Profile
	Update-Vault
	Update-Editors
	_ui_banner "Atualização Global Concluída com Sucesso"
}

### ================================
### MANUAIS E DOCUMENTACAO
### ================================

function Windows-Manual {
	param([string]$term)
	Start-Process "https://learn.microsoft.com/en-us/search/?terms=$term"
}

function Unix-Manual {
	param([string] $section, [string] $command)
	$number = $section
	if (-not [char]::IsDigit($section[-1])) { $number = $section -replace ".$" }
	wsl w3m "https://www.man7.org/linux/man-pages/man$number/$command.$section.html"
}

function Wsl-Manual {
	param([parameter(ValueFromRemainingArguments=$true)][string[]] $Args)
	wsl man $Args
}

### ================================
### ALIASES
### ================================

New-Alias "show" "Show-Explorer"
New-Alias "clr" "clear"
New-Alias "ip" "Get-IP"

New-Alias "mkledit" "Edit-MakeLua"

New-Alias "admin" "Start-Admin"
New-Alias "admin-wt" "Start-Windows-Terminal-Admin"
New-Alias "admin-ch" "Start-Console-Host-Admin"

New-Alias "upget" "Update-Winget"
New-Alias "upscp" "Update-Scoop"
New-Alias "upcho" "Update-Choco"
New-Alias "upsys" "Update-System"
New-Alias "upsh" "Update-Shell"
New-Alias "upmod" "Update-Module"
New-Alias "upwin" "Update-Windows"
New-Alias "upgit" "Update-Git"
New-Alias "uped" "Update-Editors"
New-Alias "uprc" "Update-Profile"
New-Alias "upprofile" "Update-Profile"
New-Alias "upvt" "Update-Vault"
New-Alias "upall" "Update-All"

New-Alias "brw" "Browser-Search"
New-Alias "win-man" "Windows-Manual"
New-Alias "wman" "Windows-Manual"
New-Alias "unix-man" "Unix-Manual"
New-Alias "uman" "Unix-Manual"
New-Alias "mandoc" "Unix-Manual"
New-Alias "wsl-man" "Wsl-Manual"

### ================================
### SERVER ALIASES
### ================================

function Resolve-VaultSshKey([string]$explicitKey, [string]$keyName) {
	if ($explicitKey -and (Test-Path $explicitKey)) { return $explicitKey }
	$homeDir = if ($env:USERPROFILE) { $env:USERPROFILE } elseif ($env:HOME) { $env:HOME } else { "~" }
	$candidates = @(
		(if ($env:VAULT_DIR) { Join-Path $env:VAULT_DIR "keys\$keyName" }),
		(Join-Path $homeDir ".local\share\vault\keys\$keyName"),
		(Join-Path $homeDir ".config\vault\keys\$keyName"),
		(Join-Path $homeDir ".vault\keys\$keyName")
	)
	if ($MsysHome) {
		$candidates += @(
			(Join-Path $MsysHome ".local\share\vault\keys\$keyName"),
			(Join-Path $MsysHome ".config\vault\keys\$keyName"),
			(Join-Path $MsysHome ".vault\keys\$keyName")
		)
	}
	return ($candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1)
}

function frigo-server {
	$ip = if ($env:FRIGO_SERVER_IP) { $env:FRIGO_SERVER_IP } else { "144.22.210.65" }
	$user = if ($env:FRIGO_SERVER_USER) { $env:FRIGO_SERVER_USER } else { "ubuntu" }
	$key = Resolve-VaultSshKey $env:FRIGO_SERVER_KEY "ssh-key-frigo-server.key"
	if ($key) {
		$env:FRIGO_SERVER_KEY = $key
		ssh -i $key "${user}@${ip}" $args
	} else {
		ssh "${user}@${ip}" $args
	}
}

function orbs-server {
	$ip = if ($env:ORBS_SERVER_IP) { $env:ORBS_SERVER_IP } else { "137.131.238.161" }
	$user = if ($env:ORBS_SERVER_USER) { $env:ORBS_SERVER_USER } else { "ubuntu" }
	$key = Resolve-VaultSshKey $env:ORBS_SERVER_KEY "ssh-key-orbs-server.key"
	if ($key) {
		$env:ORBS_SERVER_KEY = $key
		ssh -i $key "${user}@${ip}" $args
	} else {
		ssh "${user}@${ip}" $args
	}
}

### ================================
### EMACS ALIASES
### ================================

function ek { taskkill /IM emacs.exe /F }
function es { runemacs --fg-daemon }
function ec { emacsclientw --create-frame --alternate-editor "" $args }
function oe {
	$app = "emacsclientw"
	$target = if ($args) { $args } else { "." }
	$argList = @("--create-frame", "--alternate-editor", '""', $target)
	Start-Process -FilePath $app -ArgumentList $argList -WindowStyle Hidden
}

### ================================
### CODE EDITORS ALIASES
### ================================

function on {
	$app = "nvim"
	$target = if ($args) { $args } else { "." }
	& $app $target
}

function ov {
	$app = "vim"
	$target = if ($args) { $args } else { "." }
	& $app $target
}

function oc {
	$app = "code"
	$target = if ($args) { $args } else { "." }
	Start-Process -FilePath $app -ArgumentList $target -WindowStyle Hidden
}

function ocm {
	$app = "codium"
	$target = if ($args) { $args } else { "." }
	Start-Process -FilePath $app -ArgumentList $target -WindowStyle Hidden
}

function oz {
	$app = "zed"
	$target = if ($args) { $args } else { "." }
	Start-Process -FilePath $app -ArgumentList $target -WindowStyle Hidden
}

function oa {
	$app = "antigravity-ide"
	$target = if ($args) { $args } else { "." }
	Start-Process -FilePath $app -ArgumentList $target -WindowStyle Hidden
}

function ant {
	$app = "antigravity-ide"
	if ($args) {
		Start-Process -FilePath $app -ArgumentList $args -WindowStyle Hidden
	} else {
		Start-Process -FilePath $app -WindowStyle Hidden
	}
}
