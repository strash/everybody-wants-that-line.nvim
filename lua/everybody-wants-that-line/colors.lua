local util = require("everybody-wants-that-line.util")

local M = {}

local prefix = "EverybodyWantsThat"

-- colors
local colors = {}

-- color groups
M.color_group_names = {}

-- getting hightlight group color
local function get_hl_group_color(group_name, color)
	local hex = "FFFFFF"
	local rgb = {}
	local group_table = vim.api.nvim_get_hl_by_name(group_name, true)
	if group_table[color] ~= nil then
		hex = string.format("%06x", group_table[color]):upper()
		table.insert(rgb, tonumber(hex:sub(1,2), 16))
		table.insert(rgb, tonumber(hex:sub(3,4), 16))
		table.insert(rgb, tonumber(hex:sub(5,6), 16))
	end
	return { hex = hex, rgb = rgb }
end

-- blend colors
local function blend_colors(intensity, from, to)
	local hex = ""
	local rgb = {}
	for i = 1, 3 do
		local l = math.floor(util.lerp(intensity, from[i], to[i]))
		hex = hex .. string.format("%02x", l)
		table.insert(rgb, l)
	end
	return { hex = hex, rgb = rgb }
end

-- setting colors
local function set_colors()
	-- base colors
	colors = {
		bg = get_hl_group_color("StatusLine", "background"),
		fg = get_hl_group_color("StatusLine", "foreground"),
		bg_nc = get_hl_group_color("StatusLineNC", "background"),
		fg_nc = get_hl_group_color("StatusLineNC", "foreground"),
		fg_error = get_hl_group_color("DiagnosticError", "foreground"),
		fg_warn = get_hl_group_color("DiagnosticWarn", "foreground"),
		fg_info = get_hl_group_color("DiagnosticInfo", "foreground"),
	}
	-- blended colors
	for i = 10, 90, 10 do
		colors["fg_" .. i] = blend_colors(i / 100, colors.bg.rgb, colors.fg.rgb)
		colors["fg_nc_" .. i] = blend_colors(i / 100, colors.bg_nc.rgb, colors.fg_nc.rgb)
	end
	colors.fg_error_50 = blend_colors(0.5, colors.bg.rgb, colors.fg_error.rgb)
	colors.fg_warn_50 = blend_colors(0.5, colors.bg.rgb, colors.fg_warn.rgb)
	colors.fg_info_50 = blend_colors(0.5, colors.bg.rgb, colors.fg_info.rgb)
end

-- setting color groups names
local function set_color_group_names()
	for k, _ in pairs(colors) do
		M.color_group_names[k] = prefix .. util.pascalcase(k)
		M.color_group_names[k .. "_bold"] = prefix .. util.pascalcase(k .. "_bold")
	end
end

-- setting hightlight group
local function set_hl_group(color_group, fg, cterm)
	vim.cmd("hi " .. color_group .. util.cterm(cterm) .. "guifg=#" .. fg .. " guibg=#" .. colors.bg.hex)
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

-- formatted color group
function M.get_statusline_group(color_group)
	return "%#" .. color_group .. "#"
end

set_colors()
set_color_group_names()
set_hl_groups()

local everybody_wants_that_line_color_group = vim.api.nvim_create_augroup("EverybodyWantsThatLineColorGroup", {
	clear = true,
})

vim.api.nvim_create_autocmd({
	"OptionSet",
}, {
	pattern = "background",
	callback = function ()
		set_colors()
		set_hl_groups()
	end,
	group = everybody_wants_that_line_color_group,
})

vim.api.nvim_create_autocmd({
	"VimEnter",
	"ColorScheme",
}, {
	pattern = "*",
	callback = function ()
		set_colors()
		set_hl_groups()
	end,
	group = everybody_wants_that_line_color_group,
})

return M
