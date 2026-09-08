$env.config.buffer_editor = "code";
$env.config.show_banner = false;

$env.PATH = ($env.PATH | append $"($env.HOME)/.platformio/penv/bin");
$env.PATH = ($env.PATH | append $"($env.HOME)/.cargo/bin");

$env.PATH = (
	$env.PATH
	| split row (char esep)
	| prepend ($env.HOME | path join .local bin)
	| prepend ($env.HOME | path join .cargo bin)
	| prepend ($env.HOME | path join .platformio penv bin)
	| uniq
	| where { |p| $p | path exists }
)

$env.EMACS_SOCKET_NAME = ($env.HOME | path join ".emacs.d" "var" "server" "auth" "server");
$env.MICRO_TRUECOLOR = 1;

source "~/.oh-my-posh.nu";
