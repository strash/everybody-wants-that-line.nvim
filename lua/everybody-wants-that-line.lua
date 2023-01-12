local CO = require("everybody-wants-that-line.controller")
local UU = require("everybody-wants-that-line.utils.util")

local M = {}

-- TODO: add support for buffer_manager, lazy
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
	local content

	-- NORMAL
	if wintype == "normal" then
		content = {
			CO.get_buffer(),
			CO.get_diagnostics(),
			CO.get_quickfix(),
			CO.get_branch_status(),
			CO.get_filepath(),
			CO.get_filesize(),
			CO.get_ruller(true, true, true),
		}
	-- LOCLIST
	elseif wintype == "loclist" then
		content = {
			CO.spaced_text(CO.title("Location List in development")),
		}
	-- QUICKFIX
	elseif wintype == "quickfix" then
		content = {
			CO.get_quickfix()
		}
	-- PREVIEW
	elseif wintype == "preview" then
		content = {
			CO.spaced_text(CO.title("Preview")),
		}
	-- HELP
	elseif wintype == "help" then
		content = {
			CO.get_buffer(),
			CO.get_help(),
			CO.get_ruller(true, false, true),
		}
	-- NETRW
	elseif wintype == "netrw" then
		content = {
			CO.get_buffer(),
			CO.get_treedir("Netrw"),
		}
	-- NVIMTREE
	elseif wintype == "nvimtree" then
		content = {
			CO.spaced_text(CO.title("NvimTree"))
		}
	-- DIRBUF
	elseif wintype == "dirbuf" then
		content = {
			CO.get_buffer(),
			CO.get_treedir("Dirbuf"),
		}
	-- PACKER
	elseif wintype == "packer" then
		content = {
			CO.spaced_text(CO.title("Packer"))
		}
	-- NEOGIT
	elseif wintype == "neogit" then
		content = {
			CO.get_branch_status_text("Neogit")
		}
	-- FUGITIVE
	elseif wintype == "fugitive" then
		content = {
			CO.get_branch_status_text("Fugitive")
		}
	-- TELESCOPE
	elseif wintype == "telescope" then
		content = {
			CO.spaced_text(CO.title("Telescope"))
		}
	-- UNKNOWN
	elseif wintype == "unknown" then
		content = {
			CO.spaced_text(CO.title([[¯\_(ツ)_/¯]]))
		}
	end

	return table.concat(content)
end

---Callback for setting statusline
---@param cb function
local function callback(cb)
	vim.schedule(function()
		if cb ~= nil then
			cb()
		end
		-- NOTE: dont ever ever ever change this line
		local statusline = [[%{%v:lua.require('everybody-wants-that-line')._set_statusline()%}]]
		vim.api.nvim_win_set_option(0, "statusline", statusline)
	end)
end

---Setup that line
---@param opts opts
function M.setup(opts)
	CO.init(opts, callback)
end

return M
