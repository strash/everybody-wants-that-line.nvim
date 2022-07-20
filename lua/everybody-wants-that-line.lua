local CO = require("everybody-wants-that-line.controller")
local UU = require("everybody-wants-that-line.utils.util")

local M = {}

-- TODO: fix: quickfix list in `laststatus=2` shows 0 of 0
-- TODO: change color of the buffer prefix to `fg_60` and cache it
-- TODO: colorized bufmod_flag + (green) or - (red) and cache them
-- TODO: reversed colors
-- TODO: details in loclist
-- TODO: update screenshots
-- TODO: packer floating window

---Sets that line
---@return string
function M.set_statusline()
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
	vim.opt.statusline = [[%{%luaeval("require('everybody-wants-that-line').set_statusline()")%}]]
end

---Setup that line
---@param opts opts
function M.setup(opts)
	CO.init(opts, callback)
end

return M
