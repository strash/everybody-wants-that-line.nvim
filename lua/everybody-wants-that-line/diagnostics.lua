local colors = require("everybody-wants-that-line.colors")

local M = {}

M.get_diagnostics = function ()
	local errors = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
	local warnings = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
	local hints_infos = vim.diagnostic.get(0, { severity = { min = vim.diagnostic.severity.HINT, max = vim.diagnostic.severity.INFO } })

	local error_group, warnings_group, hints_and_info_group = "", "", ""
	local err, warn, info = 0, 0, 0

	if #errors > 0 then
		error_group = colors.get_statusline_group(colors.color_groups.error)
		err = #errors .. " (" .. errors[1].lnum + 1 .. ")"
	end
	if #warnings > 0 then
		warnings_group = colors.get_statusline_group(colors.color_groups.warning)
		warn = #warnings .. " (" .. warnings[1].lnum + 1 .. ")"
	end
	if #hints_infos > 0 then
		hints_and_info_group = colors.get_statusline_group(colors.color_groups.hint_and_info)
		info = #hints_infos .. " (" .. hints_infos[1].lnum + 1 .. ")"
	end

	return error_group .. err .. "%*, " .. warnings_group .. warn .. "%*, " .. hints_and_info_group .. info .. "%*"
end

return M