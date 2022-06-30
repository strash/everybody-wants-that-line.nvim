local B = require("everybody-wants-that-line.components")
local C = require("everybody-wants-that-line.colors")
local D = require("everybody-wants-that-line.diagnostics")
local S = require("everybody-wants-that-line.settings")
local U = require("everybody-wants-that-line.util")

local M = {}

-- TODO: add options to filename format
-- TODO: update settings. breaking_changes
-- TODO: support for Quickfix List, Location List, Prompt(telescope) - use vim.fn.win_gettype()
-- TODO: support for StatusLineNC (if multiple statuslines)
-- TODO: update README and screenshots
-- TODO: inverted colors like in gruvbox theme

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
		local help = B:highlight_text("Help", C.color_group_names.fg_60_bold)
		content = table.concat({
			B:buff_mod_flag(),
			B:buff_nr(),
			B.separator,
			B:spaced_text(help .. B.space .. buff_name:match("[%s%w_]-%.%w-$")),
			B.separator,
			B:ln(),
			B.comma,
			B.space,
			B:loc(),
		})
	-- Packer
	elseif is_packer then
		content = B:spaced_text("Packer")
	-- Fugitive
	elseif is_fugitive then
		content = B:spaced_text(B:fugitive())
	-- Other
	else
		content = table.concat({
			B:buff_mod_flag(),
			B:buff_nr(),
			B.separator,
			D.get_diagnostics(),
			B.separator,
			B:spaced_text(B:center()),
			B.separator,
			B:ln(),
			B.comma,
			B.space,
			B:col(),
			B.comma,
			B.space,
			B:loc(),
		})
	end

	vim.opt.statusline = content
end

function M.setup(opts)
	S:setup(opts)
end

local everybody_wants_that_line_group = vim.api.nvim_create_augroup(U.prefix .. "Group", {
	clear = true,
})

C.setup_autocmd(everybody_wants_that_line_group)

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
