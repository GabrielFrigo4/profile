# ----------------------------------------------------------------
# Module: NuShell Environment Setup
# ----------------------------------------------------------------

$env.config.buffer_editor = "code";
$env.config.show_banner = false;

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
