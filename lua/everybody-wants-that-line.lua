local CO = require("everybody-wants-that-line.controller")
local UU = require("everybody-wants-that-line.utils.util")

local M = {}

-- TODO: cut pwd from the path if it's relative
-- TODO: details in loclist
-- TODO: update screenshots
-- TODO: packer floating window
-- TODO: add modes

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
			CO.spaced_text("Location List"),
		}
	-- QUICKFIX
	elseif wintype == "quickfix" then
		content = {
			CO.get_quickfix()
		}
	-- PREVIEW
	elseif wintype == "preview" then
		content = {
			CO.spaced_text("Preview"),
		}
	-- HELP
	elseif wintype == "help" then
		content = {
			CO.get_buffer(),
			CO.get_help(),
			CO.get_ruller(true, false, true),
		}
	-- NVIMTREE
	elseif wintype == "nvimtree" then
		content = {
			CO.spaced_text("NvimTree"),
		}
	-- PACKER
	elseif wintype == "packer" then
		content = {
			CO.spaced_text("Packer")
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
			CO.spaced_text("Telescope")
		}
	-- UNKNOWN
	elseif wintype == "unknown" then
		content = {
			CO.spaced_text([[¯\_(ツ)_/¯]])
		}
	end

	return table.concat(content)
end

---Callback for setting statusline
local function callback()
	vim.schedule(function()
		vim.api.nvim_set_option("statusline", [[%{%v:lua.require('everybody-wants-that-line')._set_statusline()%}]])
	end)
end

---Setup that line
---@param opts opts
function M.setup(opts)
	CO.init(opts, callback)
end

return M
