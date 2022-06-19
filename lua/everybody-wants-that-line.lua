local gitbranch = require("everybody-wants-that-line.gitbranch")
local settings = require("everybody-wants-that-line.settings")
local util = require("everybody-wants-that-line.util")
local diagnostics = require("everybody-wants-that-line.diagnostics")
local colors = require("everybody-wants-that-line.colors")

local M = {}

local S = {
	spacer = "%=",
	space = " ",
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
	return separator_color_group .. S.space .. settings.separator .. S.space .. S.eocg
end

S.separator = get_separator()

local function get_secondory_text(text, is_bold)
	local color_group = colors.get_statusline_group(colors.color_groups.secondary)
	if is_bold then
		color_group = colors.get_statusline_group(colors.color_groups.secondary_bold)
	end
	return color_group .. text .. S.eocg
end

local function get_buffer_number()
	local buffer_zeroes, buffer_number = util.get_formatted_buffer_number()
	local zeroes = ""
	if #buffer_zeroes > 0 then
		zeroes = get_secondory_text(buffer_zeroes, false)
	end
	return zeroes .. buffer_number
end

local function set_statusline_content()
	local left_side = S.space .. "b" .. S.buffer_modified_flag .. S.space .. get_buffer_number()
	local line = "↓" .. S.space .. S.percentage_in_lines .. S.percent
	local column = "→" .. S.space .. S.column_idx
	local loc = S.loc .. S.space .. "LOC" .. S.space

	local buffer_name = vim.api.nvim_buf_get_name(0)
	local buffer_name_nvimtree = buffer_name:find("NvimTree")
	local buffer_name_packer = buffer_name:match("%[%w-%]$")
	local buffer_name_doc = buffer_name:find("/doc/") and buffer_name:find(".txt")
	local buffer_name_fugitive = buffer_name:find(".git/index")

	local content = ""
	if buffer_name_nvimtree then
		content = S.spacer .. "NvimTree" .. S.spacer
	elseif buffer_name_doc then
		local help_file_name = buffer_name:match("[%s%w_]-%.%w-$")
		content = left_side .. S.spacer .. get_secondory_text("Help", true) .. S.space .. help_file_name .. S.spacer .. line .. S.separator .. loc
	elseif buffer_name_packer then
		content = S.spacer .. "Packer" .. S.spacer
	elseif buffer_name_fugitive then
		content = S.spacer .. "Fugitive" .. S.spacer
	else
		local branch_name = gitbranch.get_git_branch()
		local diag = S.separator .. diagnostics.get_diagnostics() .. S.spacer
		local center = get_secondory_text(gitbranch.get_git_branch(), true) .. S.space .. S.path_to_the_file .. S.spacer
		if #branch_name == 0 then
			center = S.path_to_the_file .. S.spacer
		end
		content = left_side .. diag .. center .. line .. S.separator .. column .. S.separator .. loc
	end

	vim.opt.statusline = content

	--vim.pretty_print(vim.api.nvim_eval_statusline(content, {}))
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
