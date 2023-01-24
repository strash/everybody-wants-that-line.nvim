local CE = require("everybody-wants-that-line.components.elements")
local CO = require("everybody-wants-that-line.controller")
local UU = require("everybody-wants-that-line.utils.util")

local M = {}

-- TODO: details in loclist
-- TODO: add modes
--n	Normal mode
--v	Visual and Select mode
--x	Visual mode
--s	Select mode
--o	Operator-pending mode
--i	Insert mode
--l	Language-Argument ("r", "f", "t", etc.)
--c	Command-line mode



---Sets that line
---@return string
function M._set_statusline()
	local wintype = UU.get_wintype()

	---@type string[]
	local components

	-- NORMAL
	if wintype == "normal" then
		components = {
			CO.get_buffer(),
			CO.get_diagnostics(),
			CO.get_quickfix(),
			CE.spaced_text(UU.join({
				CO.title(CO.get_branch_name()),
				CO.get_branch_status(),
				CO.get_filepath(),
			}, CE.el.space)),
			CO.get_filesize(),
			CO.get_ruller(true, true, true),
		}
	-- LOCLIST
	elseif wintype == "loclist" then
		components = {
			CE.spaced_text(CO.title("Location List in development")),
		}
	-- QUICKFIX
	elseif wintype == "quickfix" then
		components = {
			CO.get_quickfix()
		}
	-- PREVIEW
	elseif wintype == "preview" then
		components = {
			CE.spaced_text(CO.title("Preview")),
		}
	-- HELP
	elseif wintype == "help" then
		components = {
			CO.get_buffer(),
			CO.get_help(),
			CO.get_ruller(true, false, true),
		}
	-- PACKER
	elseif wintype == "packer" then
		components = {
			CE.spaced_text(CO.title("Packer"))
		}
	-- LAZY
	elseif wintype == "lazy" then
		components = {
			CE.spaced_text(CO.title("Lazy"))
		}
	-- NETRW
	elseif wintype == "netrw" then
		components = {
			CO.get_buffer(),
			CO.get_treedir("Netrw"),
		}
	-- TELESCOPE
	elseif wintype == "telescope" then
		components = {
			CE.spaced_text(CO.title("Telescope"))
		}
	-- BUFFER MANAGER
	elseif wintype == "buffer_manager" then
		components = {
			CE.spaced_text(CO.title("Buffer Manager"))
		}
	-- NVIMTREE
	elseif wintype == "nvimtree" then
		components = {
			CE.spaced_text(CO.title("NvimTree"))
		}
	-- NEO TREE
	elseif wintype == "neo-tree" then
		components = {
			CE.spaced_text(CO.title("Neo-tree"))
		}
	-- DIRBUF
	elseif wintype == "dirbuf" then
		components = {
			CO.get_buffer(),
			CO.get_treedir("Dirbuf"),
		}
	-- NEOGIT
	elseif wintype == "neogit" then
		components = {
			CE.spaced_text(UU.join({
				CO.title("Neogit"),
				CO.get_branch_status(),
				CO.bold(CO.get_branch_name()),
			}, CE.el.space)),
		}
	-- FUGITIVE
	elseif wintype == "fugitive" then
		components = {
			CE.spaced_text(UU.join({
				CO.title("Fugitive"),
				CO.get_branch_status(),
				CO.bold(CO.get_branch_name()),
			}, CE.el.space)),
		}
	-- UNKNOWN
	elseif wintype == "unknown" then
		components = {
			CE.spaced_text(CO.title([[¯\_(ツ)_/¯]]))
		}
	end

	return CE.with_offset(UU.join(components, CO.separator()))
end

---Callback for setting statusline
local function callback()
	-- NOTE: dont ever ever ever change this line
	local statusline = [[%{%v:lua.require('everybody-wants-that-line')._set_statusline()%}]]
	vim.api.nvim_win_set_option(0, "statusline", statusline)
end

---Setup that line
---@param opts opts
function M.setup(opts)
	CO.init(opts, callback)
end

return M
