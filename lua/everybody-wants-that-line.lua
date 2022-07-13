local CO = require("everybody-wants-that-line.controller")
local UU = require("everybody-wants-that-line.utils.util")

local M = {}

-- TODO: details in quickfix and loclist
-- TODO: update screenshots
-- TODO: packer floating window

-- setting that line
function M.set_statusline()
	local wintype = UU.get_wintype()

	local content

	-- NORMAL
	if wintype == "normal" then
		content = {
			CO.bufmod_flag(),
			CO.buff_nr(),
			CO.separator(),
			CO.get_diagnostics(),
			CO.separator(),
			CO.center_with_git_status(CO.file_path()),
			CO.space(),
			CO.file_size(),
			CO.separator(),
			CO.ln(),
			CO.comma(),
			CO.space(),
			CO.col(),
			CO.comma(),
			CO.space(),
			CO.loc(),
		}
	-- LOCLIST
	elseif wintype == "loclist" then
		content = {
			CO.spaced_text("Location List"),
		}
	-- QUICKFIX
	elseif wintype == "quickfix" then
		content = {
			CO.quickfix()
		}
	-- PREVIEW
	elseif wintype == "preview" then
		content = {
			CO.spaced_text("Preview"),
		}
	-- HELP
	elseif wintype == "help" then
		content = {
			CO.bufmod_flag(),
			CO.buff_nr(),
			CO.separator(),
			CO.help(),
			CO.separator(),
			CO.ln(),
			CO.comma(),
			CO.space(),
			CO.loc(),
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
			CO.center_with_git_status("Neogit")
		}
	-- FUGITIVE
	elseif wintype == "fugitive" then
		content = {
			CO.center_with_git_status("Fugitive")
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

local function callback()
	vim.cmd([[set stl=%{%v:lua.require('everybody-wants-that-line').set_statusline()%}]])
end

---Setup that line
---@param opts opts
function M.setup(opts)
	CO.setup(opts)
	callback()
end

---Auto commands
---@type string
local autocmd_group = vim.api.nvim_create_augroup(UU.prefix .. "Group", {
	clear = true,
})

CO.setup_autocmd(autocmd_group, callback)

return M
