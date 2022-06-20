local M = {}

local prefix = "EverybodyWantsThat"

-- colors
local colors = {}

-- color groups
M.color_groups = {
	error = prefix .. "Err",
	warning = prefix .. "Warning",
	hint_and_info = prefix .. "Info",
	separator = prefix .. "Separator",
	primary = prefix .. "Primary",
	primary_bold = prefix .. "PrimaryBold",
	secondary = prefix .. "Secondary",
	secondary_bold = prefix .. "SecondaryBold",
}

-- getting hightlight group color
local function get_hl_group_color(group_name, color)
	local hl_color = "#FFFFFF"
	local group_table = vim.api.nvim_get_hl_by_name(group_name, true)
	if group_table[color] ~= nil then
		hl_color = string.format("#%06x", group_table[color])
	end
	return hl_color
end

-- setting hightlight group
local function set_hl_group(color_group, fg, cterm)
	local opt = " "
	if cterm ~= nil and type(cterm) == "string" and #cterm > 0 then
		opt = " cterm=" .. cterm .. " gui=" .. cterm .. " "
	end
	vim.cmd("hi " .. color_group .. opt .. "guifg=" .. fg .. " guibg=" .. colors.bg_statusline)
end

-- setting colors
local function set_colors()
	colors = {
		bg_statusline = get_hl_group_color("StatusLine", "background"),
		fg_statusline = get_hl_group_color("StatusLine", "foreground"),
		fg_diagnostic_error = get_hl_group_color("DiagnosticError", "foreground"),
		fg_diagnostic_warn = get_hl_group_color("DiagnosticWarn", "foreground"),
		fg_diagnostic_info = get_hl_group_color("DiagnosticInfo", "foreground"),
		fg_separator = get_hl_group_color("VertSplit", "foreground"),
		fg_secondary = get_hl_group_color("NonText", "foreground"),
	}

	set_hl_group(M.color_groups.primary, colors.fg_statusline, nil)
	set_hl_group(M.color_groups.primary_bold, colors.fg_statusline, "bold")
	set_hl_group(M.color_groups.secondary, colors.fg_secondary, nil)
	set_hl_group(M.color_groups.secondary_bold, colors.fg_secondary, "bold")
	set_hl_group(M.color_groups.error, colors.fg_diagnostic_error, "bold")
	set_hl_group(M.color_groups.warning, colors.fg_diagnostic_warn, "bold")
	set_hl_group(M.color_groups.hint_and_info, colors.fg_diagnostic_info, "bold")
	set_hl_group(M.color_groups.separator, colors.fg_separator, nil)
end

-- formatted color group
function M.get_statusline_group(color_group)
	return "%#" .. color_group .. "#"
end

set_colors()

local everybody_wants_that_line_color_group = vim.api.nvim_create_augroup("EverybodyWantsThatLineColorGroup", {
	clear = true,
})

vim.api.nvim_create_autocmd({
	"OptionSet",
}, {
	pattern = "background",
	callback = set_colors,
	group = everybody_wants_that_line_color_group,
})

vim.api.nvim_create_autocmd({
	"VimEnter",
	"ColorScheme",
}, {
	pattern = "*",
	callback = set_colors,
	group = everybody_wants_that_line_color_group,
})

return M
