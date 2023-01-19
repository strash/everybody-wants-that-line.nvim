local CU = require("everybody-wants-that-line.utils.color")
local U = require("everybody-wants-that-line.utils.util")

local M = {}

---`color_cache`
---@type { [string]: color_palette }
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

---Sets colors
local function set_colors()
	-- base colors
	cache.bg = CU.get_hl_group_color("StatusLine", "background")
	cache.fg = CU.get_hl_group_color("StatusLine", "foreground")
	cache.bg_nc = CU.get_hl_group_color("StatusLineNC", "background")
	cache.fg_nc = CU.get_hl_group_color("StatusLineNC", "foreground")
	cache.fg_error = CU.get_hl_group_color("DiagnosticError", "foreground")
	cache.fg_warn = CU.get_hl_group_color("DiagnosticWarn", "foreground")
	cache.fg_hint = CU.get_hl_group_color("DiagnosticHint", "foreground")
	cache.fg_info = CU.get_hl_group_color("DiagnosticInfo", "foreground")
	cache.fg_nc_error = cache.fg_error
	cache.fg_nc_warn = cache.fg_warn
	cache.fg_nc_hint = cache.fg_hint
	cache.fg_nc_info = cache.fg_info
	-- diff colors
	local fg_diff_add = CU.choose_right_color("DiffAdd", 2)
	local fg_diff_delete = CU.choose_right_color("DiffDelete", 1)
	cache.fg_diff_add = CU.adjust_color(fg_diff_add, cache.fg_info)
	cache.fg_diff_delete = CU.adjust_color(fg_diff_delete, cache.fg_info)
	cache.fg_nc_diff_add = cache.fg_diff_add
	cache.fg_nc_diff_delete = cache.fg_diff_delete
	-- blended colors
	for _, v in ipairs({ 20, 30, 50, 60 }) do
		cache["fg_" .. v] = CU.blend_colors(v / 100, cache.bg, cache.fg)
		cache["fg_nc_" .. v] = CU.blend_colors(v / 100, cache.bg_nc, cache.fg_nc)
	end
	-- blended colors
	local diagnostics = { "error", "warn", "hint", "info", "diff_add", "diff_delete" }
	for _, color in ipairs(diagnostics) do
		cache["fg_" .. color .. "_50"] = CU.blend_colors(0.5, cache.bg, cache["fg_" .. color])
		cache["fg_nc_" .. color .. "_50"] = CU.blend_colors(0.5, cache.bg_nc, cache["fg_" .. color])
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

---Init colors
function M.init()
	set_colors()
	set_color_group_names()
	set_hl_groups()
end

return M
