local components = require("everybody-wants-that-line.components")
local settings = require("everybody-wants-that-line.settings")
local diagnostics = require("everybody-wants-that-line.diagnostics")
local colors = require("everybody-wants-that-line.colors")

local M = {}

-- DONE: move C to util or somewhere else
-- TODO: use get_highlighted_text in diagnostics
-- TODO: add highlights to arrows in diagnostics
-- TODO: update README
-- TODO: update settings
-- TODO: move setup to settings and call a callback from here

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
		content = components:get_simple_line("NvimTree")
	-- Help
	elseif is_help then
		content = table.concat({
			components:left_side_buff_flag(),
			components:get_buffer_number(),
			components.spacer,
			components:get_highlighted_text("Help", colors.color_group_names.fg_60_bold),
			components.space,
			buff_name:match("[%s%w_]-%.%w-$"),
			components.spacer,
			components:right_side_ln(),
			components.separator,
			components:right_side_loc(),
		})
	-- Packer
	elseif is_packer then
		content = components:get_simple_line("Packer")
	-- Fugitive
	elseif is_fugitive then
		content = components:get_simple_line("Fugitive")
		-- Other
	else
		content = table.concat({
			components:left_side_buff_flag(),
			components:get_buffer_number(),
			components.separator,
			diagnostics.get_diagnostics(),
			components.spacer,
			components:center(),
			components.spacer,
			components:right_side_ln(),
			components.separator,
			components:right_side_col(),
			components.separator,
			components:right_side_loc(),
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
