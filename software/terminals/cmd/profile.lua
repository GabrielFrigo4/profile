-- ################################
-- # Startup
-- ################################

local function CLINK_DIR() return [[C:\Program Files\Shell\clink]] end
local function SYSTEM32_DIR() return [[C:\Windows\System32]] end
local function SYSTEM32_PATH(file) return SYSTEM32_DIR() .. [[\]] .. file end

local startup = {
	cwd = os.getcwd(),
}

-- ################################
-- # System
-- ################################

local function exists(path)
	local ok, err, code = os.rename(path, path)
	if ok then
		return true
	elseif not ok then
		if code == 13 then
			return true
		end
	end
	return false, err, code
end

local function is_dir(path)
	return (exists(path .. "/") and exists(path))
end

local function is_file(path)
	return (not exists(path .. "/") and exists(path))
end

local current = {
	prompt = nil,
	branch = nil,
	venv = nil,
	cwd = nil,
	dir = nil,
}

-- ################################
-- # Constant
-- ################################

local function IO_POPEN_SIZE() return 0 end
local function DEFAULT_USER_NAME() return "gabriel" end
local function DEFAULT_BRANCH_DATA() return "" end

-- ################################
-- # Functions
-- ################################

-- String
local function trim(s)
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

-- String
local function split(str, pattern)
	local str_list = {}
	for chunk in str:gmatch("[^" .. pattern .. "]+") do
		table.insert(str_list, chunk)
	end
	return str_list
end

-- Array
local function last(list)
	return list[#list]
end

-- File
local function size(file)
	return file:seek("end")
end

-- Admin
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

-- User
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

-- Git
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

-- Info
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

-- Icon
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

-- Prompt
local function extract_prompt(prompt)
	local prompt_venv = string.match(prompt, "^%((.-)%)")
	local prompt_cwd = os.getcwd()
	local prompt_dir = last(split(prompt_cwd, "\\"))
	if prompt_cwd == os.getenv("HOME") then
		prompt_dir = "~"
	end

	local prompt_info = {
		venv = prompt_venv,
		cwd = prompt_cwd,
		dir = prompt_dir,
	}
	return prompt_info
end

-- ################################
-- # Constant Colors
-- ################################

-- Default
local function GET_RESET() return "\x1b[0m" end
local function GET_BOLD() return "\x1b[1m" end
local function GET_ITALIC() return "\x1b[3m" end
local function GET_UNDERLINE() return "\x1b[4m" end

-- Color Basic
local function GET_BLACK() return "0" end
local function GET_RED() return "1" end
local function GET_GREEN() return "2" end
local function GET_YELLOW() return "3" end
local function GET_BLUE() return "4" end
local function GET_MAGENTA() return "5" end
local function GET_CYAN() return "6" end
local function GET_WHITE() return "7" end

-- ################################
-- # Functions Colors
-- ################################

-- Color Create
local function create_rgb_color(r, g, b)
	local color = {
		r = r,
		g = g,
		b = b,
	}
	return color
end

-- Color Set
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

-- text_color
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

-- background_color
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

-- text_bright_color
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

-- background_bright_color
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

-- ################################
-- # Variables
-- ################################

local admin = get_admin()
local user = get_user()
local info = get_win_info()
local icon = get_win_icon()

-- ################################
-- # Appearance
-- ################################

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

	local info = clink.promptcoroutine(get_git_branch)
	if info ~= nil then
		if info.branch ~= nil then
			prompt = prompt .. " " ..
				text_yellow("❮") .. text_bright_magenta("  ") .. text_bright_red(info.branch) .. text_yellow("❯")
		end
		current.branch = info.branch
	elseif info == nil and current.branch ~= nil then
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

-- ################################
-- # Aliases
-- ################################

local aliases = {
	-- ################################
	-- # My Shortcuts
	-- ################################
	["upget"] = [[winget upgrade --all]],
	["upscp"] = [[scoop update && scoop update --all]],
	["upcho"] = [[sudo wt choco upgrade all]],
	["upall"] = [[winget upgrade --all && scoop update && scoop update --all && sudo wt choco upgrade all]],

	["frigo-server"] = [[ssh -i ]] .. os.getenv("FRIGO_SERVER_KEY") .. [[ "ubuntu@]] .. os.getenv("FRIGO_SERVER_IP") .. [["]],
	["orbs-server"] = [[ssh -i ]] .. os.getenv("ORBS_SERVER_KEY") .. [[ "ubuntu@]] .. os.getenv("ORBS_SERVER_IP") .. [["]],

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

	-- ################################
	-- # Console and Terminal
	-- ################################
	["clear"] = [[cls]],

	-- ################################
	-- # Files and Directories
	-- ################################
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

	-- ################################
	-- # System and Processes
	-- ################################
	["ps"] = [[tasklist]],
	["kill"] = [[taskkill /F /IM]],
	["top"] = [[taskmgr]],
	["htop"] = [[taskmgr]],
	["uname"] = [[ver]],
	["history"] = [[doskey /history]],
	["man"] = [[help]],
	["reboot"] = [[shutdown /r /t 0]],
	["poweroff"] = [[shutdown /s /t 0]],

	-- ################################
	-- # Disk Utils and Info
	-- ################################
	["free"] = [[busybox free -m]],
	["who"] = [[quser]],
	["wc"] = [[busybox wc]],
	["diff"] = [[busybox diff --color=auto]],

	-- ################################
	-- # Search and Network
	-- ################################
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

-- ################################
-- # Lua Command (LuaCMD)
-- ################################

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
