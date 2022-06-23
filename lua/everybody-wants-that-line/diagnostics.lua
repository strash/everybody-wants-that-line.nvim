local B = require("everybody-wants-that-line.components")
local C = require("everybody-wants-that-line.colors")

local M = {}

M.get_diagnostics = function ()
	local errors = vim.diagnostic.get(0, {
		severity = vim.diagnostic.severity.ERROR
	})
	local warnings = vim.diagnostic.get(0, {
		severity = vim.diagnostic.severity.WARN
	})
	local hints_infos = vim.diagnostic.get(0, {
		severity = {
			min = vim.diagnostic.severity.HINT,
			max = vim.diagnostic.severity.INFO
		}
	})

	local err, warn, info = 0, 0, 0

	if #errors > 0 then
		err = table.concat({
			B:highlight_text(#errors, C.color_group_names.fg_error_bold),
			B.space,
			B:highlight_text("↓", C.color_group_names.fg_error_50),
			B:highlight_text(errors[1].lnum + 1, C.color_group_names.fg_error)
		})
	end
	if #warnings > 0 then
		warn = table.concat({
			B:highlight_text(#warnings, C.color_group_names.fg_warn_bold),
			B.space,
			B:highlight_text("↓", C.color_group_names.fg_warn_50),
			B:highlight_text(warnings[1].lnum + 1, C.color_group_names.fg_warn),
		})
	end
	if #hints_infos > 0 then
		info = table.concat({
			B:highlight_text(#hints_infos, C.color_group_names.fg_info_bold),
			B.space,
			B:highlight_text("↓", C.color_group_names.fg_info_50),
			B:highlight_text(hints_infos[1].lnum + 1, C.color_group_names.fg_info),
		})
	end

	return err .. B.comma .. B.space .. warn .. B.comma .. B.space .. info
end

return M
