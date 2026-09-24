-- ----------------------------------------------------------------
-- Module: Windows CMD Clink Prompt & Profile
-- ----------------------------------------------------------------

-- ================================
-- STARTUP
-- ================================

local function CLINK_DIR() return [[C:\Program Files\Shell\clink]] end
local function SYSTEM32_DIR() return [[C:\Windows\System32]] end
local function SYSTEM32_PATH(file) return SYSTEM32_DIR() .. [[\]] .. file end

local startup = {
	cwd = os.getcwd(),
}

-- ================================
-- SYSTEM
-- ================================

local function is_dir(p)
	if not p or p == "" then return false end
	if path and path.is_dir then return path.is_dir(p) end
	if os.isdir then return os.isdir(p) end
	local ok, _, code = os.rename(p, p)
	if ok or code == 13 or code == 17 then return true end
	return false
end

local function is_file(p)
	if not p or p == "" then return false end
	if path and path.is_file then return path.is_file(p) end
	if os.isfile then return os.isfile(p) end
	local f = io.open(p, "r")
	if f then f:close() return true end
	return false
end

local function exists(p)
	if not p or p == "" then return false end
	return is_dir(p) or is_file(p)
end

local function is_git_repo(dir)
	if not dir or dir == "" then return false end
	if path and path.is_dir and path.is_dir(dir .. [[\.git]]) then return true end
	if os.isdir and os.isdir(dir .. [[\.git]]) then return true end
	local f = io.open(dir .. [[\.git\HEAD]], "r") or io.open(dir .. [[\.git\config]], "r") or io.open(dir .. [[\.git]], "r")
	if f then
		f:close()
		return true
	end
	return false
end

-- ================================
-- ENVIRONMENT
-- ================================

local current = {
	prompt = nil,
	branch = nil,
	venv = nil,
	cwd = nil,
	dir = nil,
}

-- ================================
-- MSYS2 ENVIRONMENT
-- ================================

local function trim(s)
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

local function get_msys2_home()
	local explicit = os.getenv("MSYS2_HOME")
	if explicit and is_dir(explicit) then return explicit end

	local root = os.getenv("MSYS2_ROOT") or [[C:\msys64]]
	local home_base = root .. [[\home]]
	if not is_dir(home_base) then return nil end

	local user = os.getenv("MSYS2_USER") or os.getenv("USERNAME") or ""
	if user ~= "" then
		if is_dir(home_base .. [[\]] .. user) then
			return home_base .. [[\]] .. user
		end
		if is_dir(home_base .. [[\]] .. string.lower(user)) then
			return home_base .. [[\]] .. string.lower(user)
		end
	end

	local pipe = io.popen([[dir "]] .. home_base .. [[" /b /ad 2>nul]])
	if pipe then
		for line in pipe:lines() do
			local folder = trim(line)
			if folder ~= "" and is_dir(home_base .. [[\]] .. folder) then
				pipe:close()
				return home_base .. [[\]] .. folder
			end
		end
		pipe:close()
	end

	return nil
end

MSYS_HOME = get_msys2_home()

-- ================================
-- CONSTANT
-- ================================

local function IO_POPEN_SIZE() return 0 end
local function DEFAULT_USER_NAME() return "gabriel" end
local function DEFAULT_BRANCH_DATA() return "" end

-- ================================
-- FUNCTIONS
-- ================================

local function split(str, pattern)
	local str_list = {}
	for chunk in str:gmatch("[^" .. pattern .. "]+") do
		table.insert(str_list, chunk)
	end
	return str_list
end

local function last(list)
	return list[#list]
end

local function size(file)
	return file:seek("end")
end

local function get_admin()
	local handle = io.popen(SYSTEM32_PATH("whoami") .. [[ /groups | ]] .. SYSTEM32_PATH("find") .. [[ " S-1-16-12288 "]])
	if handle == nil then
		return false
	end
	local content = handle:read("*l")
	handle:close()

	if content == nil then
		return false
	end
	local admin = #content > IO_POPEN_SIZE()
	return admin
end

local function get_user()
	local handle = io.popen(SYSTEM32_PATH("whoami"))
	if handle == nil then
		return DEFAULT_USER_NAME()
	end
	local content = handle:read("*l")
	handle:close()

	if content == nil then
		return DEFAULT_USER_NAME()
	end
	return last(split(content, "\\"))
end

local function get_git_branch()
	local handle = io.popen([[git symbolic-ref --short HEAD 2>nul]])
	if handle == nil then
		return { branch = DEFAULT_BRANCH_DATA() }
	end
	local content = handle:read("*a")
	handle:close()

	if content == nil then
		return { branch = DEFAULT_BRANCH_DATA() }
	end
	local branch_data = content:match("(.+)\n")
	local branch_info = {
		branch = branch_data,
	}
	return branch_info
end

local function get_win_info()
	local handle = io.popen("ver")
	if handle == nil then return "WinNT" end
	local content = handle:read("*a")
	handle:close()

	local build = content:match("10%.0%.(%d+)")
	if build then
		if tonumber(build) >= 22000 then
			return "Win 11"
		else
			return "Win 10"
		end
	end
	return "WinNT"
end

local function get_win_icon()
	local handle = io.popen("ver")
	if handle == nil then return "" end
	local content = handle:read("*a")
	handle:close()

	local build = content:match("10%.0%.(%d+)")
	if build then
		if tonumber(build) >= 22000 then
			return ""
		else
			return ""
		end
	end
	return ""
end

local function extract_prompt(prompt)
	local prompt_venv = string.match(prompt, "^%((.-)%)")
	local prompt_cwd = os.getcwd()
	local prompt_dir = last(split(prompt_cwd, "\\"))
	if prompt_cwd == os.getenv("HOME") or prompt_cwd == os.getenv("USERPROFILE") or (MSYS_HOME and prompt_cwd == MSYS_HOME) then
		prompt_dir = "~"
	end

	local prompt_info = {
		venv = prompt_venv,
		cwd = prompt_cwd,
		dir = prompt_dir,
	}
	return prompt_info
end

-- ================================
-- CONSTANT COLORS
-- ================================

local function GET_RESET() return "\x1b[0m" end
local function GET_BOLD() return "\x1b[1m" end
local function GET_ITALIC() return "\x1b[3m" end
local function GET_UNDERLINE() return "\x1b[4m" end

local function GET_BLACK() return "0" end
local function GET_RED() return "1" end
local function GET_GREEN() return "2" end
local function GET_YELLOW() return "3" end
local function GET_BLUE() return "4" end
local function GET_MAGENTA() return "5" end
local function GET_CYAN() return "6" end
local function GET_WHITE() return "7" end

-- ================================
-- FUNCTIONS COLORS
-- ================================

local function create_rgb_color(r, g, b)
	local color = {
		r = r,
		g = g,
		b = b,
	}
	return color
end

local function set_text_color(color)
	return "\x1b[3" .. color .. "m"
end

local function set_background_color(color)
	return "\x1b[4" .. color .. "m"
end

local function set_text_bright_color(color)
	return "\x1b[9" .. color .. "m"
end

local function set_background_bright_color(color)
	return "\x1b[10" .. color .. "m"
end

local function set_text_extra_color(color)
	return "\x1b[38;5;" .. color .. "m"
end

local function set_background_extra_color(color)
	return "\x1b[48;5;" .. color .. "m"
end

local function set_text_rgb_color(color)
	return "\x1b[38;2;" .. color.r .. ";" .. color.g .. ";" .. color.b .. "m"
end

local function set_background_rgb_color(color)
	return "\x1b[48;2;" .. color.r .. ";" .. color.g .. ";" .. color.b .. "m"
end

local function text_black(str)
	return set_text_color(GET_BLACK()) .. str .. GET_RESET()
end
local function text_red(str)
	return set_text_color(GET_RED()) .. str .. GET_RESET()
end
local function text_green(str)
	return set_text_color(GET_GREEN()) .. str .. GET_RESET()
end
local function text_yellow(str)
	return set_text_color(GET_YELLOW()) .. str .. GET_RESET()
end
local function text_blue(str)
	return set_text_color(GET_BLUE()) .. str .. GET_RESET()
end
local function text_magenta(str)
	return set_text_color(GET_MAGENTA()) .. str .. GET_RESET()
end
local function text_cyan(str)
	return set_text_color(GET_CYAN()) .. str .. GET_RESET()
end
local function text_white(str)
	return set_text_color(GET_WHITE()) .. str .. GET_RESET()
end

local function background_black(str)
	return set_background_color(GET_BLACK()) .. str .. GET_RESET()
end
local function background_red(str)
	return set_background_color(GET_RED()) .. str .. GET_RESET()
end
local function background_green(str)
	return set_background_color(GET_GREEN()) .. str .. GET_RESET()
end
local function background_yellow(str)
	return set_background_color(GET_YELLOW()) .. str .. GET_RESET()
end
local function background_blue(str)
	return set_background_color(GET_BLUE()) .. str .. GET_RESET()
end
local function background_magenta(str)
	return set_background_color(GET_MAGENTA()) .. str .. GET_RESET()
end
local function background_cyan(str)
	return set_background_color(GET_CYAN()) .. str .. GET_RESET()
end
local function background_white(str)
	return set_background_color(GET_WHITE()) .. str .. GET_RESET()
end

local function text_bright_black(str)
	return set_text_bright_color(GET_BLACK()) .. str .. GET_RESET()
end
local function text_bright_red(str)
	return set_text_bright_color(GET_RED()) .. str .. GET_RESET()
end
local function text_bright_green(str)
	return set_text_bright_color(GET_GREEN()) .. str .. GET_RESET()
end
local function text_bright_yellow(str)
	return set_text_bright_color(GET_YELLOW()) .. str .. GET_RESET()
end
local function text_bright_blue(str)
	return set_text_bright_color(GET_BLUE()) .. str .. GET_RESET()
end
local function text_bright_magenta(str)
	return set_text_bright_color(GET_MAGENTA()) .. str .. GET_RESET()
end
local function text_bright_cyan(str)
	return set_text_bright_color(GET_CYAN()) .. str .. GET_RESET()
end
local function text_bright_white(str)
	return set_text_bright_color(GET_WHITE()) .. str .. GET_RESET()
end

local function background_bright_black(str)
	return set_background_bright_color(GET_BLACK()) .. str .. GET_RESET()
end
local function background_bright_red(str)
	return set_background_bright_color(GET_RED()) .. str .. GET_RESET()
end
local function background_bright_green(str)
	return set_background_bright_color(GET_GREEN()) .. str .. GET_RESET()
end
local function background_bright_yellow(str)
	return set_background_bright_color(GET_YELLOW()) .. str .. GET_RESET()
end
local function background_bright_blue(str)
	return set_background_bright_color(GET_BLUE()) .. str .. GET_RESET()
end
local function background_bright_magenta(str)
	return set_background_bright_color(GET_MAGENTA()) .. str .. GET_RESET()
end
local function background_bright_cyan(str)
	return set_background_bright_color(GET_CYAN()) .. str .. GET_RESET()
end
local function background_bright_white(str)
	return set_background_bright_color(GET_WHITE()) .. str .. GET_RESET()
end

-- ================================
-- VARIABLES
-- ================================

local admin = get_admin()
local user = get_user()
local info = get_win_info()
local icon = get_win_icon()

-- ================================
-- APPEARANCE
-- ================================

local pf = clink.promptfilter(10)
function pf:filter(prompt)
	local prompt_info = extract_prompt(prompt)
	current.venv = prompt_info.venv
	current.cwd = prompt_info.cwd
	current.dir = prompt_info.dir

	prompt = text_yellow("❮ ") .. text_yellow(" ") .. text_bright_cyan(prompt_info.dir) .. text_yellow(" ❯─")
	prompt = text_yellow("❮ ") .. text_bright_green(os.date(" %a, %d %b")) .. text_yellow(" ❯─") .. prompt
	prompt = text_yellow("┌──❮ ") .. text_bright_green(os.date(" %H:%M")) .. text_yellow(" ❯─") .. prompt
	prompt = text_bright_blue("") ..
		background_bright_blue(text_black(" " .. icon .. " " .. info .. " ")) ..
		background_bright_cyan(text_bright_blue("")) ..
		background_bright_cyan(text_black("  cmd ")) .. text_bright_cyan("\n") .. prompt

	if admin then
		prompt = prompt .. " " ..
			text_yellow("❮") .. text_bright_blue(" ") .. text_bright_red("admin") .. text_yellow("❯")
	else
		prompt = prompt .. " " ..
			text_yellow("❮") .. text_bright_blue(" ") .. text_bright_green(user) .. text_yellow("❯")
	end

	local binfo = clink.promptcoroutine(get_git_branch)
	if binfo ~= nil then
		if binfo.branch ~= nil then
			prompt = prompt .. " " ..
				text_yellow("❮") .. text_bright_magenta("  ") .. text_bright_red(binfo.branch) .. text_yellow("❯")
		end
		current.branch = binfo.branch
	elseif binfo == nil and current.branch ~= nil then
		prompt = prompt .. " " ..
			text_yellow("❮") .. text_bright_magenta("  ") .. text_bright_red(current.branch) .. text_yellow("❯")
	end

	if prompt_info.venv ~= nil then
		prompt = prompt .. " " ..
			text_yellow("❮") .. text_bright_blue(" ") .. text_bright_cyan(prompt_info.venv) .. text_yellow("❯")
	end

	prompt = prompt .. text_yellow("\n└─") .. text_bright_blue(" ")

	prompt = GET_RESET() .. prompt .. GET_RESET()
	current.prompt = prompt
	return prompt
end

function pf:transientfilter(prompt)
	return current.prompt
end

-- ================================
-- SSH KEY RESOLUTION
-- ================================

local function resolve_vault_ssh_key(explicit_key, key_name)
	if explicit_key and explicit_key ~= "" and is_file(explicit_key) then
		return explicit_key
	end
	local home = os.getenv("USERPROFILE") or os.getenv("HOME") or ""
	local candidates = {}
	local function add(p)
		if p and p ~= "" then table.insert(candidates, p) end
	end

	if os.getenv("VAULT_DIR") then
		add(os.getenv("VAULT_DIR") .. [[\keys\]] .. key_name)
	end
	if home ~= "" then
		add(home .. [[\.local\share\vault\keys\]] .. key_name)
		add(home .. [[\.config\vault\keys\]] .. key_name)
		add(home .. [[\.vault\keys\]] .. key_name)
	end
	if MSYS_HOME then
		add(MSYS_HOME .. [[\.local\share\vault\keys\]] .. key_name)
		add(MSYS_HOME .. [[\.config\vault\keys\]] .. key_name)
		add(MSYS_HOME .. [[\.vault\keys\]] .. key_name)
	end

	for _, p in ipairs(candidates) do
		if is_file(p) then
			return p
		end
	end
	return nil
end

-- ================================
-- ALIASES
-- ================================

local aliases = {
	-- --------------------------------
	-- My Shortcuts
	-- --------------------------------
	["upget"] = [[winget upgrade --all]],
	["upscp"] = [[scoop update && scoop update --all]],
	["upcho"] = [[powershell -NoProfile -Command "Start-Process choco -ArgumentList 'upgrade all -y' -Verb RunAs -Wait"]],
	["upwin"] = [[powershell -NoProfile -Command "Get-WindowsUpdate -AcceptAll -Install -AutoReboot"]],
	["upsys"] = [[winget upgrade --all && scoop update && scoop update --all && powershell -NoProfile -Command "Start-Process choco -ArgumentList 'upgrade all -y' -Verb RunAs -Wait"]],

	["goto-msys"] = [[cd /d "]] .. (MSYS_HOME or [[C:\msys64]]) .. [["]],
	["show-msys"] = [[start "" "]] .. (MSYS_HOME or [[C:\msys64]]) .. [["]],

	["frigo-server"] = (function()
		local ip = os.getenv("FRIGO_SERVER_IP") or "144.22.210.65"
		local key = resolve_vault_ssh_key(os.getenv("FRIGO_SERVER_KEY"), "ssh-key-frigo-server.key")
		if key then
			return [[ssh -i "]] .. key .. [[" "ubuntu@]] .. ip .. [["]]
		end
		return [[ssh "ubuntu@]] .. ip .. [["]]
	end)(),
	["orbs-server"] = (function()
		local ip = os.getenv("ORBS_SERVER_IP") or "137.131.238.161"
		local key = resolve_vault_ssh_key(os.getenv("ORBS_SERVER_KEY"), "ssh-key-orbs-server.key")
		if key then
			return [[ssh -i "]] .. key .. [[" "ubuntu@]] .. ip .. [["]]
		end
		return [[ssh "ubuntu@]] .. ip .. [["]]
	end)(),

	["ek"] = [[taskkill /IM emacs.exe /F]],
	["es"] = [[runemacs --fg-daemon]],
	["er"] = [[taskkill /IM emacs.exe /F && runemacs --fg-daemon]],
	["ec"] = [[emacsclientw.exe --create-frame --alternate-editor ""]],
	["oe"] = [[emacsclientw.exe --create-frame --alternate-editor "" .]],
	["ov"] = [[vim .]],
	["on"] = [[nvim .]],
	['oc'] = [[code .]],
	['ocm'] = [[codium .]],
	['oa'] = [[antigravity-ide .]],
	['oz'] = [[zed .]],
	['ant'] = [[antigravity-ide]],

	-- --------------------------------
	-- Console and Terminal
	-- --------------------------------
	["clear"] = [[cls]],

	-- --------------------------------
	-- Files and Directories
	-- --------------------------------
	["ls"] = [[busybox ls -F --color=auto]],
	["ll"] = [[busybox ls -alF --color=auto]],
	["la"] = [[busybox ls -A --color=auto]],
	["pwd"] = [[cd]],
	["cd"] = [[cd /d]],
	["cp"] = [[busybox cp -i]],
	["cpr"] = [[busybox cp -r]],
	["mv"] = [[busybox mv -i]],
	["rm"] = [[busybox rm -i]],
	["rmrf"] = [[busybox rm -rf]],
	["mkdir"] = [[md]],
	["cat"] = [[busybox cat]],
	["less"] = [[busybox less -R]],
	["head"] = [[busybox head]],
	["tail"] = [[busybox tail]],
	["touch"] = [[busybox touch]],
	["which"] = [[where]],
	["open"] = [[start]],

	-- --------------------------------
	-- System and Processes
	-- --------------------------------
	["ps"] = [[tasklist]],
	["kill"] = [[taskkill /F /IM]],
	["top"] = [[taskmgr]],
	["htop"] = [[taskmgr]],
	["uname"] = [[ver]],
	["history"] = [[doskey /history]],
	["man"] = [[help]],
	["reboot"] = [[shutdown /r /t 0]],
	["poweroff"] = [[shutdown /s /t 0]],

	-- --------------------------------
	-- Disk Utils and Info
	-- --------------------------------
	["free"] = [[busybox free -m]],
	["who"] = [[quser]],
	["wc"] = [[busybox wc]],
	["diff"] = [[busybox diff --color=auto]],

	-- --------------------------------
	-- Search and Network
	-- --------------------------------
	["grep"] = [[busybox grep --color=auto]],
	["find"] = [[busybox find]],
	["ifconfig"] = [[ipconfig]],
	["ip"] = [[ipconfig]],
	["ping"] = [[ping -t]],
	["wget"] = [[curl -O]],
	["env"] = [[set]],
	["export"] = [[set]],
}

for alias, _ in pairs(aliases) do
	local parser = clink.arg.new_parser()
	clink.arg.register_parser(alias, parser)
end

local function filter_alias(text)
	local cmd, args = text:match("^%s*(%S+)(.*)")
	if cmd and aliases[cmd] then
		return aliases[cmd] .. args
	end
	return nil
end

if clink.onfilterinput then
	clink.onfilterinput(filter_alias)
end

-- ================================
-- LUA COMMAND
-- ================================

local lua_commands = {
	["lc"] = true,
	["l"] = true,
}

local parser = clink.arg.new_parser()
for cmd, _ in pairs(lua_commands) do
	clink.arg.register_parser(cmd, parser)
end

local function run_lua_logic(code)
	local f = io.open(code, "r")
	if f then
		f:close()
		dofile(code)
		return
	end

	local func, err = load("return " .. code)
	if not func then
		func, err = load(code)
	end

	if func then
		local success, result = pcall(func)
		if success then
			if result ~= nil then
				print(result)
			end
		else
			print("[LuaCMD]: Erro de Execução Lua: " .. tostring(result))
		end
	else
		print("[LuaCMD]: Erro de Sintaxe: " .. tostring(err))
	end
end

local function filter_lua_cmd(text)
	local cmd, args = text:match("^%s*(%S+)%s+(.*)")
	if not cmd then
		cmd = text:match("^%s*(%S+)%s*$")
		args = ""
	end

	if cmd and lua_commands[cmd] then
		if #args > 0 then
			run_lua_logic(args)
		else
			print("[LuaCMD]: Digite um codigo ou arquivo para executar.")
		end
		return ""
	end
	return nil
end

if clink.onfilterinput then
	clink.onfilterinput(filter_lua_cmd)
end

-- ================================
-- EMISSAO E UI SEMANTICA
-- ================================

local function _ui_step(msg) print(text_cyan("==> ") .. msg) end
local function _ui_sub(msg)  print(text_blue("  ↳ ") .. msg) end
local function _ui_ok(msg)   print(text_green("  ✅ ") .. msg) end
local function _ui_warn(msg) print(text_yellow("  ⚠️  ") .. msg) end
local function _ui_err(msg)  io.stderr:write(text_red("  ❌ ") .. msg .. "\n") end
local function _ui_info(msg) print(text_magenta("  ℹ️  ") .. msg) end
local function _ui_banner(title)
	local sep = string.rep("=", 64)
	print("\n" .. text_cyan(sep) .. "\n  " .. title .. "\n" .. text_cyan(sep) .. "\n")
end

-- ================================
-- UPDATE COMMANDS (ECOSYSTEM)
-- ================================

local function cmd_upgit(args)
	local root = args and trim(args) or ""
	if root == "" then root = "." end

	_ui_step("Buscando e atualizando repositórios Git em: " .. root)
	print("")

	local pipe = io.popen([[for /r "]] .. root .. [[" %d in (.) do @if exist "%d\.git" echo %~fd]])
	if not pipe then
		_ui_err("Falha ao iniciar varredura Git.")
		return
	end

	local count = 0
	for line in pipe:lines() do
		local repo = trim(line)
		if repo ~= "" and is_git_repo(repo) then
			count = count + 1
			_ui_sub("Atualizando " .. repo .. "...")
			local ok = os.execute([[git -C "]] .. repo .. [[" pull --ff-only 2>nul]])
			if not ok or ok ~= 0 then
				os.execute([[git -C "]] .. repo .. [[" pull]])
			end
		end
	end
	pipe:close()

	if count == 0 then
		_ui_info("Nenhum repositório Git encontrado em " .. root .. " (profundidade máxima de busca).")
	else
		print("")
		_ui_ok("Varredura e atualização de repositórios Git concluída!")
	end
end

local function cmd_uped()
	_ui_step("Atualizando a Suíte de Editores no Windows...")
	local home = os.getenv("USERPROFILE") or os.getenv("HOME") or ""
	local appdata = os.getenv("APPDATA") or ""
	local localappdata = os.getenv("LOCALAPPDATA") or ""
	local found = false

	local emacs_dir = home .. [[\.emacs.d]]
	if not is_dir(emacs_dir) and appdata ~= "" then
		emacs_dir = appdata .. [[\.emacs.d]]
	end
	if not is_dir(emacs_dir) and MSYS_HOME then
		emacs_dir = MSYS_HOME .. [[\.emacs.d]]
	end
	if is_git_repo(emacs_dir) then
		found = true
		_ui_sub("Atualizando Emacs em " .. emacs_dir .. "...")
		os.execute([[git -C "]] .. emacs_dir .. [[" pull --ff-only]])
		if exists(emacs_dir .. [[\.gitmodules]]) then
			_ui_sub("Sincronizando submódulos Elisp...")
			os.execute([[git -C "]] .. emacs_dir .. [[" submodule update --init --recursive --remote --merge]])
		end
		_ui_ok("Emacs atualizado com sucesso!")
	end

	local helix_dir = appdata ~= "" and (appdata .. [[\helix]]) or (home .. [[\.config\helix]])
	if not is_dir(helix_dir) and is_dir(home .. [[\.config\helix]]) then
		helix_dir = home .. [[\.config\helix]]
	end
	if not is_dir(helix_dir) and MSYS_HOME and is_dir(MSYS_HOME .. [[\.config\helix]]) then
		helix_dir = MSYS_HOME .. [[\.config\helix]]
	end
	if is_git_repo(helix_dir) then
		found = true
		_ui_sub("Atualizando Helix em " .. helix_dir .. "...")
		os.execute([[git -C "]] .. helix_dir .. [[" pull --ff-only]])
		_ui_ok("Helix atualizado com sucesso!")
	end

	local nvim_dir = localappdata ~= "" and (localappdata .. [[\nvim]]) or (home .. [[\.config\nvim]])
	if not is_dir(nvim_dir) and is_dir(home .. [[\.config\nvim]]) then
		nvim_dir = home .. [[\.config\nvim]]
	end
	if not is_dir(nvim_dir) and MSYS_HOME and is_dir(MSYS_HOME .. [[\.config\nvim]]) then
		nvim_dir = MSYS_HOME .. [[\.config\nvim]]
	end
	if is_git_repo(nvim_dir) then
		found = true
		_ui_sub("Atualizando NeoVim em " .. nvim_dir .. "...")
		os.execute([[git -C "]] .. nvim_dir .. [[" pull --ff-only]])
		_ui_ok("NeoVim atualizado com sucesso!")
	end

	local vim_dir = home .. [[\vimfiles]]
	if not is_dir(vim_dir) and is_dir(home .. [[\.vim]]) then
		vim_dir = home .. [[\.vim]]
	end
	if not is_dir(vim_dir) and MSYS_HOME and is_dir(MSYS_HOME .. [[\.vim]]) then
		vim_dir = MSYS_HOME .. [[\.vim]]
	end
	if is_git_repo(vim_dir) then
		found = true
		_ui_sub("Atualizando Vim em " .. vim_dir .. "...")
		os.execute([[git -C "]] .. vim_dir .. [[" pull --ff-only]])
		_ui_ok("Vim atualizado com sucesso!")
	end

	if not found then
		_ui_info("Nenhum repositório de editor encontrado nos caminhos canônicos (~/.emacs.d, helix, nvim, vimfiles).")
	else
		_ui_ok("Suíte de Editores sincronizada com sucesso!")
	end
end

local function cmd_uprc()
	local home = os.getenv("USERPROFILE") or os.getenv("HOME") or ""
	local candidates = {}
	local function add(p)
		if p and p ~= "" then table.insert(candidates, p) end
	end

	add(os.getenv("PROFILE_DIR"))
	add(home .. [[\.local\share\profile]])
	add(home .. [[\.config\profile]])
	add(home .. [[\.profile]])
	add(home .. [[\OneDrive\Documentos\Profile]])
	add(home .. [[\Documents\Profile]])

	if MSYS_HOME then
		add(MSYS_HOME .. [[\.local\share\profile]])
		add(MSYS_HOME .. [[\.config\profile]])
		add(MSYS_HOME .. [[\.profile]])
	end

	local target = nil
	for _, p in ipairs(candidates) do
		if is_git_repo(p) then
			target = p
			break
		end
	end

	if target then
		_ui_step("Atualizando Universal Profile em: " .. target .. "...")
		local handle = io.popen([[git -C "]] .. target .. [[" status --porcelain 2>nul]])
		local status = handle and handle:read("*a") or ""
		if handle then handle:close() end
		if status and status:match("%S") then
			_ui_warn("Alterações locais não commitadas detectadas em: " .. target .. ". Ignorando git pull para preservar dados.")
		else
			os.execute([[git -C "]] .. target .. [[" pull --ff-only]])
		end
		local installer = target .. [[\install.ps1]]
		if exists(installer) then
			_ui_sub("Sincronizando dotfiles e links via install.ps1...")
			os.execute([[powershell -NoProfile -ExecutionPolicy Bypass -File "]] .. installer .. [["]])
		end
		_ui_ok("Universal Profile atualizado e sincronizado com sucesso!")
	else
		_ui_info("Repositório do Profile não encontrado.")
	end
end

local function cmd_upvt()
	local home = os.getenv("USERPROFILE") or os.getenv("HOME") or ""
	local candidates = {}
	local function add(p)
		if p and p ~= "" then table.insert(candidates, p) end
	end

	add(os.getenv("VAULT_DIR"))
	add(home .. [[\.local\share\vault]])
	add(home .. [[\.config\vault]])
	add(home .. [[\.vault]])

	if MSYS_HOME then
		add(MSYS_HOME .. [[\.local\share\vault]])
		add(MSYS_HOME .. [[\.config\vault]])
		add(MSYS_HOME .. [[\.vault]])
	end

	local target = nil
	for _, p in ipairs(candidates) do
		if is_git_repo(p) then
			target = p
			break
		end
	end

	if target then
		_ui_step("Atualizando Universal Vault em: " .. target .. "...")
		os.execute([[git -C "]] .. target .. [[" pull --ff-only]])
		_ui_ok("Universal Vault atualizado com sucesso!")
	else
		_ui_info("Repositório do Vault não encontrado.")
	end
end

local function cmd_upsh()
	local home = os.getenv("USERPROFILE") or os.getenv("HOME") or ""
	local candidates = {}
	local function add(p)
		if p and p ~= "" then table.insert(candidates, p) end
	end

	add(os.getenv("SHELL_REPO_DIR"))
	add(home .. [[\.local\share\shell]])
	add(home .. [[\.config\shell]])
	add(home .. [[\.shell]])
	add([[C:\Program Files\Shell]])

	if MSYS_HOME then
		add(MSYS_HOME .. [[\.local\share\shell]])
		add(MSYS_HOME .. [[\.config\shell]])
		add(MSYS_HOME .. [[\.shell]])
	end

	local target = nil
	for _, p in ipairs(candidates) do
		if is_git_repo(p) then
			target = p
			break
		end
	end

	if target then
		_ui_step("Atualizando Universal Shell em: " .. target .. "...")
		os.execute([[git -C "]] .. target .. [[" pull --ff-only]])
		_ui_ok("Universal Shell atualizado com sucesso!")
	else
		_ui_info("Repositório do Shell não encontrado.")
	end
end

local function cmd_upall()
	_ui_banner("Atualização Global do Ecossistema e Sistema")
	_ui_step("Atualizando gerenciadores de pacotes do sistema...")
	os.execute([[winget upgrade --all]])
	os.execute([[scoop update && scoop update --all]])
	os.execute([[powershell -NoProfile -Command "Start-Process choco -ArgumentList 'upgrade all -y' -Verb RunAs -Wait"]])
	_ui_ok("Pacotes do sistema atualizados!")
	cmd_uprc()
	cmd_upvt()
	cmd_uped()
	_ui_banner("Atualização Global Concluída com Sucesso")
end

local updater_commands = {
	["upgit"] = cmd_upgit,
	["update-git"] = cmd_upgit,
	["uped"] = cmd_uped,
	["update-editors"] = cmd_uped,
	["uprc"] = cmd_uprc,
	["upprofile"] = cmd_uprc,
	["update-profile"] = cmd_uprc,
	["upvt"] = cmd_upvt,
	["update-vault"] = cmd_upvt,
	["upsh"] = cmd_upsh,
	["update-shell"] = cmd_upsh,
	["upall"] = cmd_upall,
	["update-all"] = cmd_upall,
}

local updater_parser = clink.arg.new_parser()
for cmd, _ in pairs(updater_commands) do
	clink.arg.register_parser(cmd, updater_parser)
end

local function filter_updater_cmd(text)
	local cmd, args = text:match("^%s*(%S+)%s*(.*)")
	if cmd and updater_commands[cmd] then
		updater_commands[cmd](args)
		return ""
	end
	return nil
end

if clink.onfilterinput then
	clink.onfilterinput(filter_updater_cmd)
end
