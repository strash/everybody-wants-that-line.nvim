local gitbranch = require("everybody-wants-that-line.gitbranch")
local settings = require("everybody-wants-that-line.settings")
local util = require("everybody-wants-that-line.util")
local diagnostics = require("everybody-wants-that-line.diagnostics")
local colors = require("everybody-wants-that-line.colors")

local M = {}

local S = {
	spacer = "%=",
	separator = "",
	eocg = "%*",
	percent = "%%",
	buffer_modified_flag = "%M",
	path_to_the_file = "%f",
	percentage_in_lines = "%p",
	column_idx = "%c",
	loc = "%L",
}

local function get_separator()
	local separator_color_group = colors.get_statusline_group(colors.color_groups.separator)
	return separator_color_group .. " " .. settings.separator .. " " .. S.eocg
end

S.separator = get_separator()

local function get_buffer_number()
	local buffer_zeroes, buffer_number = util.get_formatted_buffer_number()
	local buffer_color_group = ""
	local zeroes = ""
	if #buffer_zeroes > 0 then
		buffer_color_group = colors.get_statusline_group(colors.color_groups.buffer_number_zero)
		zeroes = buffer_color_group .. buffer_zeroes .. S.eocg
	end
	return zeroes .. buffer_number
end

local function get_git_branch()
	local git_branch = gitbranch.get_git_branch()
	local gitbranch_color_group = colors.get_statusline_group(colors.color_groups.gitbranch)
	return gitbranch_color_group .. git_branch .. S.eocg
end

local function set_statusline_content()
	local left_side = " b" .. S.buffer_modified_flag .. " " .. get_buffer_number()
	local right_side = "↓ " .. S.percentage_in_lines .. S.percent .. S.separator .. "→ " .. S.column_idx .. S.separator .. S.loc .. " LOC "

	local buffer_name = vim.api.nvim_buf_get_name(0)
	local buffer_name_nvimtree = string.find(buffer_name, "NvimTree")
	local buffer_name_packer = string.match(buffer_name, "%[%w-%]$")
	local buffer_name_doc = string.find(buffer_name, "/doc/") and string.find(buffer_name, ".txt")
	local buffer_name_fugitive = string.find(buffer_name, ".git/index")

	local content = ""
	if buffer_name_nvimtree then
		content = S.spacer .. "NvimTree" .. S.spacer
	elseif buffer_name_doc then
		local help_file_name = string.match(buffer_name, "[%s%w_]-%.%w-$")
		content = left_side .. S.spacer .. "Help - " .. help_file_name .. S.spacer .. right_side
	elseif buffer_name_packer then
		content = S.spacer .. "Packer" .. S.spacer
	elseif buffer_name_fugitive then
		content = S.spacer .. "Fugitive" .. S.spacer
	else
		local diag = S.separator .. diagnostics.get_diagnostics() .. S.spacer
		local center = get_git_branch() .. S.separator .. S.path_to_the_file .. S.spacer
		content = left_side .. diag .. center .. right_side
	end

	vim.opt.statusline = content
end

M.setup = function(opts)
	if opts.buffer_number_symbol_count ~= nil and type(opts.buffer_number_symbol_count) == "number" then
		settings.buffer_number_symbol_count = opts.buffer_number_symbol_count
	end
	if opts.separator ~= nil and type(opts.separator) == "string" then
		settings.separator = opts.separator
	end
end

local everybody_wants_that_line_group = vim.api.nvim_create_augroup("EverybodyWantsThatLineGroup", {
	clear = true,
})

vim.api.nvim_create_autocmd({
	"BufAdd",
	"BufEnter",
	"BufWritePost",
	"FocusGained",
	"ColorScheme",
	"DiagnosticChanged",
}, {
	pattern = "*",
	callback = set_statusline_content,
	group = everybody_wants_that_line_group,
})

return M
