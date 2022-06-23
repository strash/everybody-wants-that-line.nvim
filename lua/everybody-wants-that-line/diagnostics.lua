local C = require("everybody-wants-that-line.colors")

local M = {}

M.get_diagnostics = function ()
	local errors = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
	local warnings = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
	local hints_infos = vim.diagnostic.get(0, { severity = { min = vim.diagnostic.severity.HINT, max = vim.diagnostic.severity.INFO } })

	local error_group, warnings_group, hints_and_info_group = "", "", ""
	local err, warn, info = 0, 0, 0

	if #errors > 0 then
		error_group = C.get_statusline_group(C.color_group_names.fg_error)
		err = #errors .. " ↓ " .. errors[1].lnum + 1
	end
	if #warnings > 0 then
		warnings_group = C.get_statusline_group(C.color_group_names.fg_warn)
		warn = #warnings .. " ↓ " .. warnings[1].lnum + 1
	end
	if #hints_infos > 0 then
		hints_and_info_group = C.get_statusline_group(C.color_group_names.fg_info)
		info = #hints_infos .. " ↓ " .. hints_infos[1].lnum + 1
	end

	return error_group .. err .. "%*, " .. warnings_group .. warn .. "%*, " .. hints_and_info_group .. info .. "%*"
end

return M
