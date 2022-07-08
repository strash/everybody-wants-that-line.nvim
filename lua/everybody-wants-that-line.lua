local B = require("everybody-wants-that-line.components")
local C = require("everybody-wants-that-line.colors")
local D = require("everybody-wants-that-line.diagnostics")
local G = require("everybody-wants-that-line.git")
local S = require("everybody-wants-that-line.settings")
local U = require("everybody-wants-that-line.util")

local M = {}

-- TODO: add options to filename format

-- setting that line
function M.set_statusline()
	local wintype = U.get_wintype()

	local content

	-- NORMAL
	if wintype == U.wintype.NORMAL then
		content = {
			B.buff_mod_flag(),
			B.buff_nr(),
			B.separator(),
			D.get_diagnostics(),
			B.separator(),
			B.center_with_git_status(B.path_to_the_file),
			B.separator(),
			B.ln(),
			B.comma(),
			B.space,
			B.col(),
			B.comma(),
			B.space,
			B.loc(),
		}
	-- LOCLIST
	elseif wintype == U.wintype.LOCLIST then
		content = {
			B.spaced_text("Location List"),
		}
	-- QUICKFIX
	elseif wintype == U.wintype.QUICKFIX then
		content = {
			B.spaced_text("Quickfix List"),
		}
	-- PREVIEW
	elseif wintype == U.wintype.PREVIEW then
		content = {
			B.spaced_text("Preview"),
		}
	-- HELP
	elseif wintype == U.wintype.HELP then
		local help = B.highlight_text("Help", C.color_group_names.fg_60_bold)
		local buff_name = vim.api.nvim_buf_get_name(0)
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
	-- NVIMTREE
	elseif wintype == U.wintype.NVIMTREE then
		content = {
			B.spaced_text("NvimTree"),
		}
	-- PACKER
	elseif wintype == U.wintype.PACKER then
		content = {
			B.spaced_text("Packer")
		}
	-- NEOGIT
	elseif wintype == U.wintype.NEOGIT then
		content = {
			B.center_with_git_status("Neogit")
		}
	-- FUGITIVE
	elseif wintype == U.wintype.FUGITIVE then
		content = {
			B.center_with_git_status("Fugitive")
		}
	-- TELESCOPE
	elseif wintype == U.wintype.TELESCOPE then
		content = {
			B.spaced_text("Telescope")
		}
	-- UNKNOWN
	elseif wintype == U.wintype.UNKNOWN then
		content = {
			B.spaced_text([[¯\_(ツ)_/¯]])
		}
	end

	return table.concat(content)
end

local function callback()
	vim.cmd([[set stl=%{%v:lua.require('everybody-wants-that-line').set_statusline()%}]])
end

-- setup method
function M.setup(opts)
	S.setup(opts)
	callback()
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
