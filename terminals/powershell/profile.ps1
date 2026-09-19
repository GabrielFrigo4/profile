<#
# ----------------------------------------------------------------
# Module: PowerShell Interactive Environment Profile
# ----------------------------------------------------------------
#>

### ================================
### CONFIGURACOES GERAIS
### ================================

$vaultDir = @(
	$env:VAULT_DIR,
	(Join-Path $HOME ".local\share\vault"),
	(Join-Path $HOME ".config\vault"),
	(Join-Path $HOME ".vault")
) | Where-Object { $_ -and (Test-Path (Join-Path $_ "vault.ps1")) } | Select-Object -First 1

if ($vaultDir) {
	. (Join-Path $vaultDir "vault.ps1")
}

$PSDefaultparameterValues['*:Encoding'] = 'utf8'

$env:HOME = $env:USERPROFILE
$SYSTEM32 = 'C:\Windows\System32'

$OneDrive  = "${Home}\onedrive"
$Desktop   = "${OneDrive}\Área de Trabalho"
$Documents = "${OneDrive}\Documentos"
$Images	= "${OneDrive}\Imagens"
$Workspace = "${OneDrive}\Workspace"
$Downloads = "${Home}\Downloads"

$VIRTUAL_STORE = "$($env:LOCALAPPDATA)\VirtualStore"
$FASM_STORE	= "${VIRTUAL_STORE}\Program Files\FASM"
$FASM2_STORE   = "${VIRTUAL_STORE}\Program Files\FASM2"
$FASMG_STORE   = "${VIRTUAL_STORE}\Program Files\FASMG"
$FASMARM_STORE = "${VIRTUAL_STORE}\Program Files\FASMARM"

$IsAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
$Machine = [Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::Machine)
$User	= [Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::User)

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
### ATUALIZACAO
### ================================

function Update-Winget { winget upgrade --all }

function Update-Scoop {
	scoop update
	scoop update --all
}

function Update-Choco {
	$process = Start-Process -FilePath "choco" -ArgumentList "upgrade all -y" -Verb RunAs -PassThru -WindowStyle Normal
	Wait-Process -InputObject $process
}

function Update-Windows {
	$cmd = "Get-WindowsUpdate -AcceptAll -Install -AutoReboot"
	$process = Start-Process -FilePath "pwsh" -ArgumentList "-Command $cmd" -Verb RunAs -PassThru -WindowStyle Normal
	Wait-Process -InputObject $process
}

function Update-System {
	Update-Winget
	Update-Scoop
	Update-Choco
}

function Update-All {
	Update-Module
	Update-System
	Update-Windows
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
New-Alias "upsh" "Update-Module"
New-Alias "upwin" "Update-Windows"
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
		if ($env:VAULT_DIR) { Join-Path $env:VAULT_DIR "keys\$keyName" },
		(Join-Path $homeDir ".local\share\vault\keys\$keyName"),
		(Join-Path $homeDir ".config\vault\keys\$keyName"),
		(Join-Path $homeDir ".vault\keys\$keyName")
	) | Where-Object { $_ -and (Test-Path $_) }
	if ($candidates) { return $candidates[0] }
	return $null
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
