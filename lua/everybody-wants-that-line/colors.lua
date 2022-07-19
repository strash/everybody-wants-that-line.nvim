local CU = require("everybody-wants-that-line.utils.color-util")
local U = require("everybody-wants-that-line.utils.util")

local M = {}

---Colors
---@type { [string]: color_palette }
local colors = { }

---Color group names:
---`bg`,
---`fg[_20|_30|_50|_60][_bold]`,
---`fg[_error[_50]|_warn[_50]|_hint[_50]|_info[_50]][_bold]`,
---`fg[_diff_add[_50]|_diff_delete[_50]][_bold]`
---
---__WARNING__: It also contains `[_nc]` groups but you don't want to use them,
---because they are handled automatically.
---@type { [string]: string }
M.group_names = { }

---Sets colors
local function set_colors()
	-- base colors
	colors.bg = CU.get_hl_group_color("StatusLine", "background")
	colors.fg = CU.get_hl_group_color("StatusLine", "foreground")
	colors.bg_nc = CU.get_hl_group_color("StatusLineNC", "background")
	colors.fg_nc = CU.get_hl_group_color("StatusLineNC", "foreground")
	colors.fg_error = CU.get_hl_group_color("DiagnosticError", "foreground")
	colors.fg_warn = CU.get_hl_group_color("DiagnosticWarn", "foreground")
	colors.fg_hint = CU.get_hl_group_color("DiagnosticHint", "foreground")
	colors.fg_info = CU.get_hl_group_color("DiagnosticInfo", "foreground")
	colors.fg_nc_error = colors.fg_error
	colors.fg_nc_warn = colors.fg_warn
	colors.fg_nc_hint = colors.fg_hint
	colors.fg_nc_info = colors.fg_info
	-- diff colors
	local fg_diff_add = CU.choose_right_color("DiffAdd", 2)
	local fg_diff_delete = CU.choose_right_color("DiffDelete", 1)
	colors.fg_diff_add = CU.adjust_color(fg_diff_add, colors.fg_info)
	colors.fg_diff_delete = CU.adjust_color(fg_diff_delete, colors.fg_info)
	colors.fg_nc_diff_add = colors.fg_diff_add
	colors.fg_nc_diff_delete = colors.fg_diff_delete
	-- blended colors
	for _, v in ipairs({ 20, 30, 50, 60 }) do
		colors["fg_" .. v] = CU.blend_colors(v / 100, colors.bg, colors.fg)
		colors["fg_nc_" .. v] = CU.blend_colors(v / 100, colors.bg_nc, colors.fg_nc)
	end
	-- diagnostics
	colors.fg_error_50 = CU.blend_colors(0.5, colors.bg, colors.fg_error)
	colors.fg_warn_50 = CU.blend_colors(0.5, colors.bg, colors.fg_warn)
	colors.fg_hint_50 = CU.blend_colors(0.5, colors.bg, colors.fg_hint)
	colors.fg_info_50 = CU.blend_colors(0.5, colors.bg, colors.fg_info)
	colors.fg_diff_add_50 = CU.blend_colors(0.5, colors.bg, colors.fg_diff_add)
	colors.fg_diff_delete_50 = CU.blend_colors(0.5, colors.bg, colors.fg_diff_delete)

	colors.fg_nc_error_50 = CU.blend_colors(0.5, colors.bg_nc, colors.fg_error)
	colors.fg_nc_warn_50 = CU.blend_colors(0.5, colors.bg_nc, colors.fg_warn)
	colors.fg_nc_hint_50 = CU.blend_colors(0.5, colors.bg, colors.fg_hint)
	colors.fg_nc_info_50 = CU.blend_colors(0.5, colors.bg_nc, colors.fg_info)
	colors.fg_nc_diff_add_50 = CU.blend_colors(0.5, colors.bg_nc, colors.fg_diff_add)
	colors.fg_nc_diff_delete_50 = CU.blend_colors(0.5, colors.bg_nc, colors.fg_diff_delete)
end

---Sets color groups names
local function set_color_group_names()
	for k, _ in pairs(colors) do
		M.group_names[k] = U.prefix .. U.pascalcase(k)
		M.group_names[k .. "_bold"] = U.prefix .. U.pascalcase(k .. "_bold")
	end
end

---Sets hightlight group
---@param group_name string
---@param fg_hex string
---@param cterm cterm
local function set_hl_group(group_name, fg_hex, cterm)
	local bg = group_name:find("Nc") == nil and colors.bg.hex or colors.bg_nc.hex
	vim.cmd("hi " .. group_name .. U.cterm(cterm) .. "guifg=#" .. fg_hex .. " guibg=#" .. bg)
end

---Sets hightlight groups
local function set_hl_groups()
	for k, v in pairs(M.group_names) do
		local b = k:find("_bold")
		if b ~= nil then
			set_hl_group(v, colors[k:sub(1, b - 1)].hex, "bold")
		else
			set_hl_group(v, colors[k].hex, "")
		end
	end
end

---Init colors
function M._init()
	set_colors()
	set_color_group_names()
	set_hl_groups()
end

return M
