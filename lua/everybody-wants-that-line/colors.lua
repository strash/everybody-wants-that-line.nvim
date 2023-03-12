---@alias color_ground '"background"'|'"foreground"'
---@alias nvim_get_hl_by_id { background: string|nil, foreground: string|nil, reverse: boolean|nil, bold: boolean|nil }

local ColorData = require("everybody-wants-that-line.utils.color")
local U = require("everybody-wants-that-line.utils.util")

local M = {}

---@type { [string]: ColorData }
local cache = {}

---Color group names:
---`bg`,
---`fg[_20|_30|_50|_60][_bold]`,
---`fg[_error[_50]|_warn[_50]|_hint[_50]|_info[_50]][_bold]`,
---`fg[_diff_add[_50]|_diff_delete[_50]][_bold]`
---
---__WARNING__: Do not use `[_nc]` groups directly, they are handled automatically.
---@type { [string]: string }
M.group_names = {}

---Get data from hl group
---@param group_name string
---@return nvim_get_hl_by_id
local function get_data_from_hl_group(group_name)
	local hl_id = vim.fn.hlID(group_name)
	---@type nvim_get_hl_by_id
	local hl_group_data = {
		background = nil, foreground = nil, bold = nil, reverse = nil
	}
	if hl_id ~= 0 then
		hl_group_data = vim.api.nvim_get_hl_by_id(hl_id, true)
	end
	return hl_group_data
end

---Static. Get hightlight group color palette
---@param hl_group_name string name of the hl group, e.g. `"StatusLine"`
---@param ground color_ground
---@return integer|nil
local function get_vim_color(hl_group_name, ground)
	local hl_group_data = get_data_from_hl_group(hl_group_name)
	if hl_group_data["reverse"] ~= nil and hl_group_data["reverse"] == true or
		not hl_group_data[ground] then
		ground = (ground == "background" and "foreground" or "background")
	end
	return hl_group_data[ground] and tonumber(hl_group_data[ground]) or nil
end

---Returns right group name. `...Nc` (not current) or current (in active StatusLine)
---@param group_name string
---@return string
local function get_group_name(group_name)
	if U.is_focused() then
		return group_name
	end
	return U.prefix .. group_name:sub(#U.prefix + 1, #U.prefix + 2) .. "Nc" .. group_name:sub(#U.prefix + 3)
end

---Returns highlighted text
---@param text string
---@param group_name string
---@param is_exact_group_name nil|boolean If `true` then return formatted `group_name`. Default is `false`
---@return string
local function highlight_text(text, group_name, is_exact_group_name)
	if is_exact_group_name == nil then
		is_exact_group_name = false
	end
	return "%#" .. (is_exact_group_name and group_name or get_group_name(group_name)) .. "#" .. text .. "%*"
end

---Sets colors
local function set_colors()
	-- base colors
	cache.bg = ColorData:new(get_vim_color("StatusLine", "background"))
	vim.pretty_print(cache.bg)
	cache.fg = ColorData:new(get_vim_color("StatusLine", "foreground"))
	vim.pretty_print(cache.bg)
	cache.bg_nc = ColorData:new(get_vim_color("StatusLineNC", "background"))
	cache.fg_nc = ColorData:new(get_vim_color("StatusLineNC", "foreground"))
	cache.fg_error = ColorData:new(get_vim_color("DiagnosticError", "foreground"))
	cache.fg_warn = ColorData:new(get_vim_color("DiagnosticWarn", "foreground"))
	cache.fg_hint = ColorData:new(get_vim_color("DiagnosticHint", "foreground"))
	cache.fg_info = ColorData:new(get_vim_color("DiagnosticInfo", "foreground"))
	cache.fg_nc_error = cache.fg_error:blend(0.8, cache.bg)
	cache.fg_nc_warn = cache.fg_warn:blend(0.8, cache.bg)
	cache.fg_nc_hint = cache.fg_hint:blend(0.8, cache.bg)
	cache.fg_nc_info = cache.fg_info:blend(0.8, cache.bg)
	-- diff colors
	local fg_diff_add = ColorData.choose_right_color(
		ColorData:new(get_vim_color("DiffAdd", "background")),
		ColorData:new(get_vim_color("DiffAdd", "foreground")), 2)
	local fg_diff_delete = ColorData.choose_right_color(
		ColorData:new(get_vim_color("DiffDelete", "background")),
		ColorData:new(get_vim_color("DiffDelete", "foreground")), 1)
	cache.fg_diff_add = fg_diff_add:adjust_color(cache.fg_info)
	cache.fg_diff_delete = fg_diff_delete:adjust_color(cache.fg_info)
	cache.fg_nc_diff_add = cache.fg_diff_add:blend(0.8, cache.bg)
	cache.fg_nc_diff_delete = cache.fg_diff_delete:blend(0.8, cache.bg)
	-- blended colors
	for _, v in ipairs({ 20, 30, 50, 60 }) do
		cache["fg_" .. v] = cache.fg:blend(v / 100, cache.bg)
		cache["fg_nc_" .. v] = cache.fg_nc:blend(v / 100, cache.bg_nc)
	end
	-- blended colors
	local diagnostics = { "error", "warn", "hint", "info", "diff_add", "diff_delete" }
	for _, color in ipairs(diagnostics) do
		cache["fg_" .. color .. "_50"] = cache["fg_" .. color]:blend(0.5, cache.bg)
		cache["fg_nc_" .. color .. "_50"] = cache["fg_nc_" .. color]:blend(0.5, cache.bg_nc)
	end
end

---Sets color groups names
local function set_color_group_names()
	for k, _ in pairs(cache) do
		M.group_names[k] = U.prefix .. U.pascalcase(k)
		M.group_names[k .. "_bold"] = U.prefix .. U.pascalcase(k .. "_bold")
	end
end

---Sets hightlight group
---@param group_name string
---@param fg_hex string
---@param cterm cterm
local function set_hl_group(group_name, fg_hex, cterm)
	local bg = group_name:find("Nc") == nil and cache.bg.hex or cache.bg_nc.hex
	vim.cmd("hi " .. group_name .. U.cterm(cterm) .. "guifg=#" .. fg_hex .. " guibg=#" .. bg)
end

---Sets hightlight groups
local function set_hl_groups()
	for k, v in pairs(M.group_names) do
		local b = k:find("_bold")
		if b ~= nil then
			set_hl_group(v, cache[k:sub(1, b - 1)].hex, "bold")
		else
			set_hl_group(v, cache[k].hex, "")
		end
	end
end

M.highlight_text = highlight_text

---Init colors
function M.init()
	set_colors()
	set_color_group_names()
	set_hl_groups()
end

return M
