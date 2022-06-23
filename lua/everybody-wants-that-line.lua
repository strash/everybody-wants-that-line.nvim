local B = require("everybody-wants-that-line.components")
local S = require("everybody-wants-that-line.settings")
local D = require("everybody-wants-that-line.diagnostics")
local C = require("everybody-wants-that-line.colors")

local M = {}

-- DONE: move C to util or somewhere else
-- DONE: move setup to settings and call a callback from here
-- TODO: use get_highlighted_text in diagnostics
-- TODO: add highlights to arrows in diagnostics
-- TODO: update settings. breaking_changes
-- TODO: update README

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
		content = B:spaced_text("NvimTree")
	-- Help
	elseif is_help then
		content = table.concat({
			B:buff_mod_flag(),
			B:buff_nr(),
			B.spacer,
			B:highlight_text("Help", C.color_group_names.fg_60_bold),
			B.space,
			buff_name:match("[%s%w_]-%.%w-$"),
			B.spacer,
			B:ln(),
			B.separator,
			B:loc(),
		})
	-- Packer
	elseif is_packer then
		content = B:spaced_text("Packer")
	-- Fugitive
	elseif is_fugitive then
		content = B:spaced_text("Fugitive")
		-- Other
	else
		content = table.concat({
			B:buff_mod_flag(),
			B:buff_nr(),
			B.separator,
			D.get_diagnostics(),
			B.spacer,
			B:center(),
			B.spacer,
			B:ln(),
			B.separator,
			B:col(),
			B.separator,
			B:loc(),
		})
	end

	vim.opt.statusline = content

	--vim.pretty_print(vim.api.nvim_eval_statusline(content, {}))
end

function M.setup(opts)
	S:setup(opts)
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
