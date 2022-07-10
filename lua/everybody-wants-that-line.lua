local B = require("everybody-wants-that-line.components")
local C = require("everybody-wants-that-line.colors")
local D = require("everybody-wants-that-line.diagnostics")
local G = require("everybody-wants-that-line.git")
local S = require("everybody-wants-that-line.settings")
local U = require("everybody-wants-that-line.util")

local M = {}

-- TODO: add SI metrics to file_size and fix binary metrics (KB -> KiB)
-- TODO: details in quickfix and loclist

-- setting that line
function M.set_statusline()
	local wintype = U.get_wintype()

	local content

	-- NORMAL
	if wintype == "normal" then
		content = {
			B.bufmod_flag(),
			B.buff_nr(),
			B.separator(),
			B.get_diagnostics(),
			B.separator(),
			B.center_with_git_status(B.file_path()),
			B.space(),
			B.file_size(),
			B.separator(),
			B.ln(),
			B.comma(),
			B.space(),
			B.col(),
			B.comma(),
			B.space(),
			B.loc(),
		}
	-- LOCLIST
	elseif wintype == "loclist" then
		content = {
			B.spaced_text("Location List"),
		}
	-- QUICKFIX
	elseif wintype == "quickfix" then
		content = {
			B.spaced_text("Quickfix List"),
		}
	-- PREVIEW
	elseif wintype == "preview" then
		content = {
			B.spaced_text("Preview"),
		}
	-- HELP
	elseif wintype == "help" then
		local help = B.highlight_text("Help", C.group_names.fg_60_bold)
		local buff_name = vim.api.nvim_buf_get_name(0)
		content = {
			B.bufmod_flag(),
			B.buff_nr(),
			B.separator(),
			B.spaced_text(help .. B.space() .. buff_name:match("[%s%w_]-%.%w-$")),
			B.separator(),
			B.ln(),
			B.comma(),
			B.space(),
			B.loc(),
		}
	-- NVIMTREE
	elseif wintype == "nvimtree" then
		content = {
			B.spaced_text("NvimTree"),
		}
	-- PACKER
	elseif wintype == "packer" then
		content = {
			B.spaced_text("Packer")
		}
	-- NEOGIT
	elseif wintype == "neogit" then
		content = {
			B.center_with_git_status("Neogit")
		}
	-- FUGITIVE
	elseif wintype == "fugitive" then
		content = {
			B.center_with_git_status("Fugitive")
		}
	-- TELESCOPE
	elseif wintype == "telescope" then
		content = {
			B.spaced_text("Telescope")
		}
	-- UNKNOWN
	elseif wintype == "unknown" then
		content = {
			B.spaced_text([[¯\_(ツ)_/¯]])
		}
	end

	return table.concat(content)
end

local function callback()
	vim.cmd([[set stl=%{%v:lua.require('everybody-wants-that-line').set_statusline()%}]])
end

---Setup that line
---@param opts opts
function M.setup(opts)
	S.setup(opts)
	callback()
end

---Auto commands
---@type string
local autocmd_group = vim.api.nvim_create_augroup(U.prefix .. "Group", {
	clear = true,
})

C.setup_autocmd(autocmd_group, callback)
B.setup_autocmd(autocmd_group, callback)
D.setup_autocmd(autocmd_group, callback)
G.setup_autocmd(autocmd_group, callback)

return M
