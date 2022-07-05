local CU = require("everybody-wants-that-line.color-util")
local U = require("everybody-wants-that-line.util")

local M = {}

-- colors
local colors = {}

-- color groups
M.color_group_names = {}

-- setting colors
local function set_colors()
	-- base colors
	colors = {
		bg = CU.get_hl_group_color("StatusLine", "background"),
		fg = CU.get_hl_group_color("StatusLine", "foreground"),
		bg_nc = CU.get_hl_group_color("StatusLineNC", "background"),
		fg_nc = CU.get_hl_group_color("StatusLineNC", "foreground"),
		fg_error = CU.get_hl_group_color("DiagnosticError", "foreground"),
		fg_warn = CU.get_hl_group_color("DiagnosticWarn", "foreground"),
		fg_info = CU.get_hl_group_color("DiagnosticInfo", "foreground"),
	}
	colors.fg_nc_error = colors.fg_error
	colors.fg_nc_warn = colors.fg_warn
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
	colors.fg_info_50 = CU.blend_colors(0.5, colors.bg, colors.fg_info)
	colors.fg_diff_add_50 = CU.blend_colors(0.5, colors.bg, colors.fg_diff_add)
	colors.fg_diff_delete_50 = CU.blend_colors(0.5, colors.bg, colors.fg_diff_delete)

	colors.fg_nc_error_50 = CU.blend_colors(0.5, colors.bg_nc, colors.fg_error)
	colors.fg_nc_warn_50 = CU.blend_colors(0.5, colors.bg_nc, colors.fg_warn)
	colors.fg_nc_info_50 = CU.blend_colors(0.5, colors.bg_nc, colors.fg_info)
	colors.fg_nc_diff_add_50 = CU.blend_colors(0.5, colors.bg_nc, colors.fg_diff_add)
	colors.fg_nc_diff_delete_50 = CU.blend_colors(0.5, colors.bg_nc, colors.fg_diff_delete)
end

-- setting color groups names
local function set_color_group_names()
	for k, _ in pairs(colors) do
		M.color_group_names[k] = U.prefix .. U.pascalcase(k)
		M.color_group_names[k .. "_bold"] = U.prefix .. U.pascalcase(k .. "_bold")
	end
end

-- setting hightlight group
local function set_hl_group(group_name, fg, cterm)
	local bg = group_name:find("Nc") == nil and colors.bg.hex or colors.bg_nc.hex
	vim.cmd("hi " .. group_name .. U.cterm(cterm) .. "guifg=#" .. fg .. " guibg=#" .. bg)
end

-- setting hightlight groups
local function set_hl_groups()
	for k, v in pairs(M.color_group_names) do
		local b = k:find("_bold")
		if b ~= nil then
			set_hl_group(v, colors[k:sub(1, b - 1)].hex, "bold")
		else
			set_hl_group(v, colors[k].hex, "")
		end
	end
end

-- auto commands
function M.setup_autocmd(group_name, cb)
	set_colors()
	set_color_group_names()
	set_hl_groups()

	vim.api.nvim_create_autocmd({
		"ColorScheme",
	}, {
		pattern = "*",
		callback = function()
			set_colors()
			set_color_group_names()
			set_hl_groups()
			cb()
		end,
		group = group_name,
	})
end

return M
