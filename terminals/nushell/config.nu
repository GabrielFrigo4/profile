# ----------------------------------------------------------------
# Module: NuShell Interactive Configuration
# ----------------------------------------------------------------

### ================================
### SHELL ENVIRONMENT
### ================================

$env.config.buffer_editor = "notepad++";
$env.config.show_banner = false;
$env.HOME = $"($env.USERPROFILE)";

let _msys_root = ($env.MSYS2_ROOT? | default "C:\\msys64")
let _msys_home_base = ($env.MSYS2_HOME? | default ([$_msys_root, "home"] | path join))
let _msys_user = ($env.MSYS2_USER? | default ($env.USERNAME? | default ""))

let _msys_target = ([$_msys_home_base, $_msys_user] | path join)
let _msys_target_lower = ([$_msys_home_base, ($_msys_user | str lowercase)] | path join)

let MsysHome = if ($_msys_target | path exists) {
	$_msys_target
} else if ($_msys_target_lower | path exists) {
	$_msys_target_lower
} else {
	""
}

let _vault_candidates = [
	($env.VAULT_DIR? | default ""),
	(($env.USERPROFILE? | default ($env.HOME? | default "~")) | path join ".local" "share" "vault"),
	(($env.USERPROFILE? | default ($env.HOME? | default "~")) | path join ".config" "vault"),
	(($env.USERPROFILE? | default ($env.HOME? | default "~")) | path join ".vault"),
	(if ($MsysHome | is-not-empty) { [$MsysHome, ".local", "share", "vault"] | path join } else { "" }),
	(if ($MsysHome | is-not-empty) { [$MsysHome, ".config", "vault"] | path join } else { "" }),
	(if ($MsysHome | is-not-empty) { [$MsysHome, ".vault"] | path join } else { "" })
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
let Documents = $"($OneDrive)\\Documentos";
let Images = $"($OneDrive)\\Imagens";
let Workspace = $"($OneDrive)\\Workspace";
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
### SSH KEY RESOLUTION
### ================================

def resolve-vault-ssh-key [explicit_key: string, key_name: string] {
	if ($explicit_key | is-not-empty) and ($explicit_key | path exists) {
		return $explicit_key
	}
	let user_home = ($env.USERPROFILE? | default ($env.HOME? | default "~"))
	let candidates = [
		(if ($env.VAULT_DIR? | is-not-empty) { [$env.VAULT_DIR, "keys", $key_name] | path join } else { "" }),
		([$user_home, ".local", "share", "vault", "keys", $key_name] | path join),
		([$user_home, ".config", "vault", "keys", $key_name] | path join),
		([$user_home, ".vault", "keys", $key_name] | path join),
		(if ($MsysHome | is-not-empty) { [$MsysHome, ".local", "share", "vault", "keys", $key_name] | path join } else { "" }),
		(if ($MsysHome | is-not-empty) { [$MsysHome, ".config", "vault", "keys", $key_name] | path join } else { "" }),
		(if ($MsysHome | is-not-empty) { [$MsysHome, ".vault", "keys", $key_name] | path join } else { "" })
	]
	$candidates | where { |p| ($p | is-not-empty) and ($p | path exists) } | get -o 0
}

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
alias upcho = ^pwsh -NoProfile -Command "Start-Process choco -ArgumentList 'upgrade all -y' -Verb RunAs -Wait";
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
alias Goto-Msys = cd (if ($MsysHome | is-not-empty) { $MsysHome } else { "C:\\msys64" });
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
alias Show-Msys = explorer.exe (if ($MsysHome | is-not-empty) { $MsysHome } else { "C:\\msys64" });

def --wrapped frigo-server [...rest] {
	let ip = ($env.FRIGO_SERVER_IP? | default "144.22.210.65")
	let user = ($env.FRIGO_SERVER_USER? | default "ubuntu")
	let key = (resolve-vault-ssh-key ($env.FRIGO_SERVER_KEY? | default "") "ssh-key-frigo-server.key")
	if ($key | is-not-empty) {
		$env.FRIGO_SERVER_KEY = $key
		ssh -i $key $"($user)@($ip)" ...$rest
	} else {
		ssh $"($user)@($ip)" ...$rest
	}
}

def --wrapped orbs-server [...rest] {
	let ip = ($env.ORBS_SERVER_IP? | default "137.131.238.161")
	let user = ($env.ORBS_SERVER_USER? | default "ubuntu")
	let key = (resolve-vault-ssh-key ($env.ORBS_SERVER_KEY? | default "") "ssh-key-orbs-server.key")
	if ($key | is-not-empty) {
		$env.ORBS_SERVER_KEY = $key
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
### EMISSAO E UI SEMANTICA
### ================================

def _ui_step [msg: string] { print $"(ansi cyan_bold)==>(ansi reset) ($msg)" }
def _ui_sub  [msg: string] { print $"(ansi blue_bold)  ↳(ansi reset) ($msg)" }
def _ui_ok   [msg: string] { print $"(ansi green_bold)  ✅(ansi reset) ($msg)" }
def _ui_warn [msg: string] { print $"(ansi yellow_bold)  ⚠️ (ansi reset) ($msg)" }
def _ui_err  [msg: string] { print -e $"(ansi red_bold)  ❌(ansi reset) ($msg)" }
def _ui_info [msg: string] { print $"(ansi magenta_bold)  ℹ️ (ansi reset) ($msg)" }
def _ui_banner [title: string] {
	let sep = "================================================================"
	print $"\n(ansi cyan_bold)($sep)\n  ($title)\n($sep)(ansi reset)\n"
}

### ================================
### SHELL FUNCTIONS
### ================================

def upscp [] {
	_ui_step "Atualizando pacotes via Scoop..."
	scoop update
	scoop update --all
	_ui_ok "Scoop atualizado com sucesso!"
}

def upwin [] {
	_ui_step "Executando Windows Update com reinicialização automática se necessário..."
	^pwsh -NoProfile -Command "Get-WindowsUpdate -AcceptAll -Install -AutoReboot"
	_ui_ok "Windows Update finalizado!"
}

def upsys [] {
	_ui_step "Atualizando gerenciadores de pacotes do sistema..."
	upget
	upscp
	upcho
	_ui_ok "Atualização de pacotes do sistema concluída!"
}

def upgit [target_dir?: string] {
	let root = if ($target_dir | is-empty) { "." } else { $target_dir }
	_ui_step $"Buscando e atualizando repositórios Git em: ($root)"
	print ""

	let g1 = (try { glob $"($root)/.git" } catch { [] })
	let g2 = (try { glob $"($root)/*/.git" } catch { [] })
	let g3 = (try { glob $"($root)/*/*/.git" } catch { [] })
	let repos = ($g1 | append $g2 | append $g3 | uniq)

	if ($repos | is-empty) {
		_ui_info $"Nenhum repositório Git encontrado em ($root) (profundidade máxima: 3)."
		return
	}

	for repo in $repos {
		let dir = ($repo | path dirname)
		_ui_sub $"Atualizando ($dir)..."
		let res = (do { ^git -C $dir pull --ff-only } | complete)
		if $res.exit_code != 0 {
			^git -C $dir pull
		}
	}
	print ""
	_ui_ok "Varredura e atualização de repositórios Git concluída!"
}

def uped [] {
	_ui_step "Atualizando a Suíte de Editores no Windows..."
	mut found = false

	let emacs_paths = [
		([$env.USERPROFILE, ".emacs.d"] | path join),
		(if ($env.APPDATA? | is-not-empty) { [$env.APPDATA, ".emacs.d"] | path join } else { "" }),
		(if ($MsysHome | is-not-empty) { [$MsysHome, ".emacs.d"] | path join } else { "" })
	]
	let emacs_dir = ($emacs_paths | where { |p| ($p | is-not-empty) and ([$p, ".git"] | path join | path exists) } | get -o 0)
	if ($emacs_dir | is-not-empty) {
		$found = true
		_ui_sub $"Atualizando Emacs em ($emacs_dir)..."
		^git -C $emacs_dir pull --ff-only
		if ([$emacs_dir, ".gitmodules"] | path join | path exists) {
			_ui_sub "Sincronizando submódulos Elisp..."
			^git -C $emacs_dir submodule update --init --recursive --remote --merge
		}
		_ui_ok "Emacs atualizado com sucesso!"
	}

	let helix_paths = [
		(if ($env.APPDATA? | is-not-empty) { [$env.APPDATA, "helix"] | path join } else { "" }),
		([$env.USERPROFILE, ".config", "helix"] | path join),
		(if ($MsysHome | is-not-empty) { [$MsysHome, ".config", "helix"] | path join } else { "" })
	]
	let helix_dir = ($helix_paths | where { |p| ($p | is-not-empty) and ([$p, ".git"] | path join | path exists) } | get -o 0)
	if ($helix_dir | is-not-empty) {
		$found = true
		_ui_sub $"Atualizando Helix em ($helix_dir)..."
		^git -C $helix_dir pull --ff-only
		_ui_ok "Helix atualizado com sucesso!"
	}

	let nvim_paths = [
		(if ($env.LOCALAPPDATA? | is-not-empty) { [$env.LOCALAPPDATA, "nvim"] | path join } else { "" }),
		([$env.USERPROFILE, ".config", "nvim"] | path join),
		(if ($MsysHome | is-not-empty) { [$MsysHome, ".config", "nvim"] | path join } else { "" })
	]
	let nvim_dir = ($nvim_paths | where { |p| ($p | is-not-empty) and ([$p, ".git"] | path join | path exists) } | get -o 0)
	if ($nvim_dir | is-not-empty) {
		$found = true
		_ui_sub $"Atualizando NeoVim em ($nvim_dir)..."
		^git -C $nvim_dir pull --ff-only
		_ui_ok "NeoVim atualizado com sucesso!"
	}

	let vim_paths = [
		([$env.USERPROFILE, "vimfiles"] | path join),
		([$env.USERPROFILE, ".vim"] | path join),
		(if ($MsysHome | is-not-empty) { [$MsysHome, ".vim"] | path join } else { "" })
	]
	let vim_dir = ($vim_paths | where { |p| ($p | is-not-empty) and ([$p, ".git"] | path join | path exists) } | get -o 0)
	if ($vim_dir | is-not-empty) {
		$found = true
		_ui_sub $"Atualizando Vim em ($vim_dir)..."
		^git -C $vim_dir pull --ff-only
		_ui_ok "Vim atualizado com sucesso!"
	}

	if (not $found) {
		_ui_info "Nenhum repositório de editor encontrado nos caminhos canônicos (~/.emacs.d, helix, nvim, vimfiles)."
	} else {
		_ui_ok "Suíte de Editores sincronizada com sucesso!"
	}
}

def uprc [] {
	let candidates = [
		($env.PROFILE_DIR? | default ""),
		([$env.USERPROFILE, ".local", "share", "profile"] | path join),
		([$env.USERPROFILE, ".config", "profile"] | path join),
		([$env.USERPROFILE, ".profile"] | path join),
		([$env.USERPROFILE, "OneDrive", "Documentos", "Profile"] | path join),
		([$env.USERPROFILE, "Documents", "Profile"] | path join),
		(if ($MsysHome | is-not-empty) { [$MsysHome, ".local", "share", "profile"] | path join } else { "" }),
		(if ($MsysHome | is-not-empty) { [$MsysHome, ".config", "profile"] | path join } else { "" }),
		(if ($MsysHome | is-not-empty) { [$MsysHome, ".profile"] | path join } else { "" })
	]
	let target = ($candidates | where { |p| ($p | is-not-empty) and ([$p, ".git"] | path join | path exists) } | get -o 0)

	if ($target | is-not-empty) {
		_ui_step $"Atualizando Universal Profile em: ($target)..."
		let dirty = (^git -C $target status --porcelain | str trim)
		if ($dirty | is-not-empty) {
			_ui_warn $"Alterações locais não commitadas detectadas em: ($target). Ignorando git pull para preservar dados."
		} else {
			^git -C $target pull --ff-only
		}
		let installer = ([$target, "install.ps1"] | path join)
		if ($installer | path exists) {
			_ui_sub "Sincronizando dotfiles e links via install.ps1..."
			^pwsh -NoProfile -ExecutionPolicy Bypass -File $installer
		}
		_ui_ok "Universal Profile atualizado e sincronizado com sucesso!"
	} else {
		_ui_info "Repositório do Profile não encontrado."
	}
}

def upvt [] {
	let candidates = [
		($env.VAULT_DIR? | default ""),
		([$env.USERPROFILE, ".local", "share", "vault"] | path join),
		([$env.USERPROFILE, ".config", "vault"] | path join),
		([$env.USERPROFILE, ".vault"] | path join),
		(if ($MsysHome | is-not-empty) { [$MsysHome, ".local", "share", "vault"] | path join } else { "" }),
		(if ($MsysHome | is-not-empty) { [$MsysHome, ".config", "vault"] | path join } else { "" }),
		(if ($MsysHome | is-not-empty) { [$MsysHome, ".vault"] | path join } else { "" })
	]
	let target = ($candidates | where { |p| ($p | is-not-empty) and ([$p, ".git"] | path join | path exists) } | get -o 0)

	if ($target | is-not-empty) {
		_ui_step $"Atualizando Universal Vault em: ($target)..."
		^git -C $target pull --ff-only
		_ui_ok "Universal Vault atualizado com sucesso!"
	} else {
		_ui_info "Repositório do Vault não encontrado."
	}
}

def upsh [] {
	let candidates = [
		($env.SHELL_REPO_DIR? | default ""),
		([$env.USERPROFILE, ".local", "share", "shell"] | path join),
		([$env.USERPROFILE, ".config", "shell"] | path join),
		([$env.USERPROFILE, ".shell"] | path join),
		"C:\\Program Files\\Shell",
		(if ($MsysHome | is-not-empty) { [$MsysHome, ".local", "share", "shell"] | path join } else { "" }),
		(if ($MsysHome | is-not-empty) { [$MsysHome, ".config", "shell"] | path join } else { "" }),
		(if ($MsysHome | is-not-empty) { [$MsysHome, ".shell"] | path join } else { "" })
	]
	let target = ($candidates | where { |p| ($p | is-not-empty) and ([$p, ".git"] | path join | path exists) } | get -o 0)

	if ($target | is-not-empty) {
		_ui_step $"Atualizando Universal Shell em: ($target)..."
		^git -C $target pull --ff-only
		_ui_ok "Universal Shell atualizado com sucesso!"
	} else {
		_ui_info "Repositório do Shell não encontrado."
	}
}

def upall [] {
	_ui_banner "Atualização Global do Ecossistema e Sistema"
	upsys
	uprc
	upvt
	uped
	_ui_banner "Atualização Global Concluída com Sucesso"
}

alias upprofile = uprc;
alias update-git = upgit;
alias update-editors = uped;
alias update-profile = uprc;
alias update-vault = upvt;
alias update-shell = upsh;
alias update-system = upsys;
alias update-all = upall;
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
