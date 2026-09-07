### ################################
### SHELL ENVIRONMENT
### ################################

$env.config.buffer_editor = "notepad++";
$env.config.show_banner = false;
$env.HOME = $"($env.USERPROFILE)";

source ~/.vault/vault.nu

### ################################
### SHELL VARIABLES
### ################################

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

### ################################
### SHELL OH-MY-POSH
### ################################

# "In Nushell"
# oh-my-posh init nu --config $"($Home)/.oh-my-posh/themes/atomic.omp.json" | save -f $"($Home)/.oh-my-posh.nu";
source "~/.oh-my-posh.nu";

### ################################
### WINDOWS FUNCTIONS
### ################################

# Manual FUNCTIONS
def win-man [term: string] {
	start $"https://learn.microsoft.com/en-us/search/?terms=($term)";
};

### ################################
### UNIX FUNCTIONS
### ################################

# Manual FUNCTIONS
def unix-man [section: string, command: string] {
	mut number = $section;
	if (not ('0123456789' | str contains ($section | str substring (-1..)))) {
		$number = $section | str substring (..-2);
	}
	wsl w3m $"https://www.man7.org/linux/man-pages/man($number)/($command).($section).html";
};

### ################################
### SHELL ALIAS
### ################################

# Software ALIAS
alias wh = which;
alias show = start .;
alias brw = lynx -use_mouse=on -nobrowse=on -nopause=on -show_cursor=off;
# Manual ALIAS
alias man = wsl man;
alias wman = win-man;
alias uman = unix-man;
alias mandoc = unix-man;
# Management ALIAS
alias upget = winget upgrade --all;
alias upcho = sudo wt choco upgrade all;
# Goto ALIAS
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
# Show ALIAS
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
# Server ALIAS
alias frigo-server = ssh -i $"($env.FRIGO_SERVER_KEY)" $"ubuntu@($env.FRIGO_SERVER_IP)";
alias orbs-server = ssh -i $"($env.ORBS_SERVER_KEY)" $"ubuntu@($env.ORBS_SERVER_IP)";
# Emacs ALIAS
alias ek = taskkill /IM emacs.exe /F;
alias es = runemacs --fg-daemon;
alias ec = emacsclientw --create-frame --alternate-editor "";
alias oe = emacsclientw --create-frame --alternate-editor "" .;
# Code Editors ALIAS
alias ov = vim .;
alias on = nvim .;
alias oc = code .;
alias ocm = codium .;
alias oz = zed .;

### ################################
### SHELL FUNCTIONS
### ################################

# Management FUNCTIONS
def upscp [] { scoop update; scoop update --all };
def upall [] { upget; upscp; upcho };
# Emacs FUNCTIONS
def er [] { ek; es };
# Antigravity FUNCTIONS
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

### ################################
### SHELL CONFIGURATION
### ################################
