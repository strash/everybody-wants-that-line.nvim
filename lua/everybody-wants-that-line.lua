local B = require("everybody-wants-that-line.components")
local C = require("everybody-wants-that-line.colors")
local D = require("everybody-wants-that-line.diagnostics")
local G = require("everybody-wants-that-line.git")
local S = require("everybody-wants-that-line.settings")
local U = require("everybody-wants-that-line.util")

local M = {}

-- TODO: add options to filename format
-- TODO: support for Quickfix List, Location List, Prompt(telescope) - use vim.fn.win_gettype()

-- setting that line
function M.set_statusline()
	local buff_name = vim.api.nvim_buf_get_name(0)
	local is_nvimtree = buff_name:find("NvimTree") ~= nil
	local is_packer = buff_name:match("%[%w-%]$")
	local is_help = buff_name:find("/doc/") ~= nil and buff_name:find(".txt") ~= nil
	local is_fugitive = buff_name:find(".git/index") ~= nil

	local content

	-- NvimTree
	if is_nvimtree then
		content = B.spaced_text("NvimTree")
	-- Help
	elseif is_help then
		local help = B.highlight_text("Help", C.color_group_names.fg_60_bold)
		content = {
			B.buff_mod_flag(),
			B.buff_nr(),
			B.separator(),
			B.spaced_text(help .. B.space .. buff_name:match("[%s%w_]-%.%w-$")),
			B.separator(),
			B.ln(),
			B.comma(),
			B.space,
			B.loc(),
		}
	-- Packer
	elseif is_packer then
		content = { B.spaced_text("Packer") }
	-- Fugitive
	elseif is_fugitive then
		content = { B.spaced_text(B.fugitive()) }
	-- Other
	else
		content = {
			B.buff_mod_flag(),
			B.buff_nr(),
			B.separator(),
			D.get_diagnostics(),
			B.separator(),
			B.spaced_text(B.center()),
			B.separator(),
			B.ln(),
			B.comma(),
			B.space,
			B.col(),
			B.comma(),
			B.space,
			B.loc(),
		}
	end

	return table.concat(content)
end

local function callback()
	vim.cmd([[set stl=%{%v:lua.require('everybody-wants-that-line').set_statusline()%}]])
end

-- setup method
function M.setup(opts)
	S:setup(opts)
end

-- auto commands
local autocmd_group = vim.api.nvim_create_augroup(U.prefix .. "Group", {
	clear = true,
})

C.setup_autocmd(autocmd_group, callback)
B.setup_autocmd(autocmd_group, callback)
D.setup_autocmd(autocmd_group, callback)
G.setup_autocmd(autocmd_group, callback)

return M
