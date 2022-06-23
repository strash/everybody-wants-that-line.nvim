local gitbranch = require("everybody-wants-that-line.gitbranch")
local settings = require("everybody-wants-that-line.settings")
local util = require("everybody-wants-that-line.util")
local diagnostics = require("everybody-wants-that-line.diagnostics")
local colors = require("everybody-wants-that-line.colors")

local M = {}

-- components
local C = {
	spacer = "%=",
	space = " ",
	eocg = "%*",
	percent = "%%",
	buffer_modified_flag = "%M",
	path_to_the_file = "%f",
	percentage_in_lines = "%p",
	column_idx = "%c",
	loc = "%L",
}

-- separator
C.separator = (function ()
	local separator_color_group = colors.get_statusline_group(colors.color_group_names.fg_20)
	return separator_color_group .. C.space .. settings.separator .. C.space .. C.eocg
end)()

-- highlighted text with secondary style
function C:get_highlighted_text(text, color_group_name)
	local cg = colors.get_statusline_group(color_group_name)
	return cg .. text .. self.eocg
end

-- text with spacers
function C:get_simple_line(text)
	return self.spacer .. text .. self.spacer
end

-- buffer modified flag
function C:left_side_buff_flag()
	return self.space .. "b" .. self.buffer_modified_flag .. self.space
end

-- buffer number
function C:get_buffer_number()
	local buffer_zeroes, buffer_number = util.get_formatted_buffer_number()
	local zeroes = ""
	if #buffer_zeroes > 0 then
		zeroes = self:get_highlighted_text(buffer_zeroes, colors.color_group_names.fg_40)
	end
	return zeroes .. self:get_highlighted_text(buffer_number, colors.color_group_names.fg_bold)
end

-- center
function C:center()
	local branch_name = gitbranch.get_git_branch()
	if #branch_name == 0 then
		return self.path_to_the_file
	end
	return self:get_highlighted_text(branch_name, colors.color_group_names.fg_60_bold) .. self.space .. self.path_to_the_file
end

-- percentage through file in lines
function C:right_side_ln()
	return self:get_highlighted_text("↓", colors.color_group_names.fg_40) .. self.space .. self.percentage_in_lines .. self.percent
end

-- column number
function C:right_side_col()
	return self:get_highlighted_text("→", colors.color_group_names.fg_40) .. self.space .. self.column_idx
end

-- lines of code
function C:right_side_loc()
	return self.loc .. self.space .. self:get_highlighted_text("LOC", colors.color_group_names.fg_40) .. self.space
end

-- setting the line
local function set_statusline_content()
	local buff_name = vim.api.nvim_buf_get_name(0)
	local is_nvimtree = buff_name:find("NvimTree") ~= nil
	local is_packer = buff_name:match("%[%w-%]$")
	local is_help = buff_name:find("/doc/") ~= nil and buff_name:find(".txt") ~= nil
	local is_fugitive = buff_name:find(".git/index") ~= nil

	local content = ""

	-- NvimTree
	if is_nvimtree then
		content = C:get_simple_line("NvimTree")
	-- Help
	elseif is_help then
		content = table.concat({
			C:left_side_buff_flag(),
			C:get_buffer_number(),
			C.spacer,
			C:get_highlighted_text("Help", colors.color_group_names.fg_60_bold),
			C.space,
			buff_name:match("[%s%w_]-%.%w-$"),
			C.spacer,
			C:right_side_ln(),
			C.separator,
			C:right_side_loc(),
		})
	-- Packer
	elseif is_packer then
		content = C:get_simple_line("Packer")
	-- Fugitive
	elseif is_fugitive then
		content = C:get_simple_line("Fugitive")
		-- Other
	else
		content = table.concat({
			C:left_side_buff_flag(),
			C:get_buffer_number(),
			C.separator,
			diagnostics.get_diagnostics(),
			C.spacer,
			C:center(),
			C.spacer,
			C:right_side_ln(),
			C.separator,
			C:right_side_col(),
			C.separator,
			C:right_side_loc(),
		})
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
	"BufModifiedSet",
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
