local M = {}

local prefix = "EverybodyWantsThat"

M.colors = {}

M.color_groups = {
	error = prefix .. "Err",
	warning = prefix .. "Warning",
	hint_and_info = prefix .. "Info",
	buffer_number_zero = prefix .. "BuffNumZero",
	separator = prefix .. "Separator",
	gitbranch = prefix .. "GitBranch",
}

local function set_hl_groups(color_group, fg)
	vim.cmd("hi " .. color_group .. " cterm=bold guifg=" .. fg .. " guibg=" .. M.colors.bg_statusline)
end

local function get_hl_group_color(group_name, color)
	local group_table = vim.api.nvim_get_hl_by_name(group_name, true)
	return string.format("#%06x", group_table[color])
end

local function set_colors()
	M.colors = {
		bg_statusline = get_hl_group_color("StatusLine", "background"),
		fg_diagnostic_error = get_hl_group_color("DiagnosticError", "foreground"),
		fg_diagnostic_warn = get_hl_group_color("DiagnosticWarn", "foreground"),
		fg_diagnostic_info = get_hl_group_color("DiagnosticInfo", "foreground"),
		fg_comment = get_hl_group_color("Comment", "foreground"),
		fg_string = get_hl_group_color("String", "foreground"),
	}

	set_hl_groups(M.color_groups.error, M.colors.fg_diagnostic_error)
	set_hl_groups(M.color_groups.warning, M.colors.fg_diagnostic_warn)
	set_hl_groups(M.color_groups.hint_and_info, M.colors.fg_diagnostic_info)
	set_hl_groups(M.color_groups.buffer_number_zero, M.colors.fg_comment)
	set_hl_groups(M.color_groups.separator, M.colors.fg_comment)
	set_hl_groups(M.color_groups.gitbranch, M.colors.fg_string)
end

M.get_statusline_group = function (color_group)
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
