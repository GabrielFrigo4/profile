# ----------------------------------------------------------------
# Module: NuShell Interactive Configuration
# ----------------------------------------------------------------

### ================================
### SHELL ENVIRONMENT
### ================================

$env.config.buffer_editor = "notepad++";
$env.config.show_banner = false;
$env.HOME = $"($env.USERPROFILE)";
let _vault_candidates = [
	($env.VAULT_DIR? | default ""),
	(($env.USERPROFILE? | default ($env.HOME? | default "~")) | path join ".local" "share" "vault"),
	(($env.USERPROFILE? | default ($env.HOME? | default "~")) | path join ".config" "vault"),
	(($env.USERPROFILE? | default ($env.HOME? | default "~")) | path join ".vault")
]
let _active_vault = ($_vault_candidates | where { |p| ($p | is-not-empty) and ($p | path exists) } | get -o 0)

if ($_active_vault | is-not-empty) {
    let _pattern = ($"($_active_vault)/**/*.env" | str replace -a '\' '/')
    for f in (glob $_pattern) {
		let raw_lines = (open $f | lines | where { |it|
			let trimmed = ($it | str trim)
			($trimmed | is-not-empty) and (not ($trimmed | str starts-with '#')) and ($trimmed | str contains '=')
		})
		for line in $raw_lines {
			let parts = ($line | split row -n 2 '=')
			let key = ($parts | get 0 | str trim)
			mut val = ($parts | get 1 | str trim | str replace -r '^"(.*)"$' '$1' | str replace -r "^'(.*)'$" '$1')
			$val = ($val | str replace -r '\$\{VAULT_DIR:-[^\}]+\}' $_active_vault)
			$val = ($val | str replace -a '${VAULT_DIR}' $_active_vault | str replace -a '$VAULT_DIR' $_active_vault)
			$val = ($val | str replace -a '${HOME}' ($env.USERPROFILE? | default ($env.HOME? | default "~")) | str replace -a '$HOME' ($env.USERPROFILE? | default ($env.HOME? | default "~")))
			load-env { $key: $val }
		}
	}
}
### ================================
### SHELL VARIABLES
### ================================

let Home = $"($env.USERPROFILE)";
let System32 = "C:\\Windows\\System32";
let OneDrive = $"($Home)\\onedrive";
let Desktop = $"($OneDrive)\\Área de Trabalho";
let Documents = $"($OneDrive)\\Documentos" ;
let Images = $"($OneDrive)\\Imagens";
let Workspace = $"($OneDrive)\\Workspace" ;
let Downloads = $"($Home)\\Downloads";
let VIRTUAL_STORE = $"($env.LOCALAPPDATA)\\VirtualStore";
let FASM_STORE = $"($VIRTUAL_STORE)\\Program Files\\FASM";
let FASM2_STORE = $"($VIRTUAL_STORE)\\Program Files\\FASM2";
let FASMG_STORE = $"($VIRTUAL_STORE)\\Program Files\\FASMG";
let FASMARM_STORE = $"($VIRTUAL_STORE)\\Program Files\\FASMARM";

### ================================
### SHELL OH-MY-POSH
### ================================

source "~/.oh-my-posh.nu";

### ================================
### WINDOWS FUNCTIONS
### ================================

def win-man [term: string] {
	start $"https://learn.microsoft.com/en-us/search/?terms=($term)";
};

### ================================
### UNIX FUNCTIONS
### ================================

def unix-man [section: string, command: string] {
	mut number = $section;
	if (not ('0123456789' | str contains ($section | str substring (-1..)))) {
		$number = $section | str substring (..-2);
	}
	wsl w3m $"https://www.man7.org/linux/man-pages/man($number)/($command).($section).html";
};

### ================================
### SHELL ALIASES
### ================================

alias wh = which;
alias show = start .;
alias brw = lynx -use_mouse=on -nobrowse=on -nopause=on -show_cursor=off;
alias man = wsl man;
alias wman = win-man;
alias uman = unix-man;
alias mandoc = unix-man;
alias upget = winget upgrade --all;
alias upcho = sudo wt choco upgrade all;
alias Goto-Home = cd $"($Home)";
alias Goto-OneDrive = cd $"($OneDrive)";
alias Goto-Desktop = cd $"($Desktop)";
alias Goto-Documents = cd $"($Documents)";
alias Goto-Workspace = cd $"($Workspace)";
alias Goto-Images = cd $"($Images)";
alias Goto-Downloads = cd $"($Downloads)";
alias Goto-Virtual-Store = cd $"($VIRTUAL_STORE)";
alias Goto-FASM-Store = cd $"($FASM_STORE)";
alias Goto-Machine = cd $"($System32)";
alias Show-Explorer = explorer.exe .;
alias Show-Home = explorer.exe $"($Home)";
alias Show-OneDrive = explorer.exe $"($OneDrive)";
alias Show-Desktop = explorer.exe $"($Desktop)";
alias Show-Documents = explorer.exe $"($Documents)";
alias Show-Workspace = explorer.exe $"($Workspace)";
alias Show-Images = explorer.exe $"($Images)";
alias Show-Downloads = explorer.exe $"($Downloads)";
alias Show-Virtual-Store = explorer.exe $"($VIRTUAL_STORE)";
alias Show-FASM-Store = explorer.exe $"($FASM_STORE)";
alias Show-Machine = explorer.exe $"($System32)";
def --wrapped frigo-server [...rest] {
	let ip = ($env.FRIGO_SERVER_IP? | default "144.22.210.65")
	let user = ($env.FRIGO_SERVER_USER? | default "ubuntu")
	let key = ($env.FRIGO_SERVER_KEY? | default "")
	if ($key | is-not-empty) and ($key | path exists) {
		ssh -i $key $"($user)@($ip)" ...$rest
	} else {
		ssh $"($user)@($ip)" ...$rest
	}
}

def --wrapped orbs-server [...rest] {
	let ip = ($env.ORBS_SERVER_IP? | default "137.131.238.161")
	let user = ($env.ORBS_SERVER_USER? | default "ubuntu")
	let key = ($env.ORBS_SERVER_KEY? | default "")
	if ($key | is-not-empty) and ($key | path exists) {
		ssh -i $key $"($user)@($ip)" ...$rest
	} else {
		ssh $"($user)@($ip)" ...$rest
	}
}
alias ek = taskkill /IM emacs.exe /F;
alias es = runemacs --fg-daemon;
alias ec = emacsclientw --create-frame --alternate-editor "";
alias oe = emacsclientw --create-frame --alternate-editor "" .;
alias ov = vim .;
alias on = nvim .;
alias oc = code .;
alias ocm = codium .;
alias oz = zed .;

### ================================
### SHELL FUNCTIONS
### ================================

def upscp [] { scoop update; scoop update --all };
def upall [] { upget; upscp; upcho };
def er [] { ek; es };
def oa [...args: string] {
	let app = "antigravity-ide"
	let target = if ($args | is-empty) { "." } else { $args | str join " " }
	^pwsh -NoProfile -Command $"Start-Process -FilePath '($app)' -ArgumentList '($target)' -WindowStyle Hidden"
}
def ant [...args: string] {
	let app = "antigravity-ide"
	if ($args | is-empty) {
		^pwsh -NoProfile -Command $"Start-Process -FilePath '($app)' -WindowStyle Hidden"
	} else {
		let args_str = ($args | str join " ")
		^pwsh -NoProfile -Command $"Start-Process -FilePath '($app)' -ArgumentList '($args_str)' -WindowStyle Hidden"
	}
}

### ================================
### SHELL CONFIGURATION
### ================================
