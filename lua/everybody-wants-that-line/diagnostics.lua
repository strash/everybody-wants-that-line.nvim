local B = require("everybody-wants-that-line.components")
local C = require("everybody-wants-that-line.colors")
local U = require("everybody-wants-that-line.util")

local M = {}

M.cache = {
	diagnostics = ""
}

function M.get_diagnostics()
	local laststatus = U.laststatus()
	if laststatus == 3 and M.cache.diagnostics ~= "" then
		return M.cache.diagnostics
	else
		local bufnr
		if laststatus == 3 then
			bufnr = vim.api.nvim_get_current_buf()
		else
			bufnr = U.is_focused() and tonumber(vim.g.actual_curbuf) or vim.api.nvim_get_current_buf()
		end
		local is_lsp_attached = #vim.lsp.get_active_clients() > 0
		if is_lsp_attached then
			local errors = vim.diagnostic.get(bufnr, {
				severity = vim.diagnostic.severity.ERROR
			})
			local warnings = vim.diagnostic.get(bufnr, {
				severity = vim.diagnostic.severity.WARN
			})
			local hints_infos = vim.diagnostic.get(bufnr, {
				severity = {
					min = vim.diagnostic.severity.HINT,
					max = vim.diagnostic.severity.INFO
				}
			})

			local err, warn, info = "0", "0", "0"

			if #errors > 0 then
				err = table.concat({
					B.highlight_text(#errors, C.color_group_names.fg_error_bold),
					B.space,
					B.highlight_text("↓", C.color_group_names.fg_error_50),
					B.highlight_text(errors[1].lnum + 1, C.color_group_names.fg_error)
				})
			end
			if #warnings > 0 then
				warn = table.concat({
					B.highlight_text(#warnings, C.color_group_names.fg_warn_bold),
					B.space,
					B.highlight_text("↓", C.color_group_names.fg_warn_50),
					B.highlight_text(warnings[1].lnum + 1, C.color_group_names.fg_warn),
				})
			end
			if #hints_infos > 0 then
				info = table.concat({
					B.highlight_text(#hints_infos, C.color_group_names.fg_info_bold),
					B.space,
					B.highlight_text("↓", C.color_group_names.fg_info_50),
					B.highlight_text(hints_infos[1].lnum + 1, C.color_group_names.fg_info),
				})
			end

			return err .. B.comma() .. B.space .. warn .. B.comma() .. B.space .. info
		else
			return "0, 0, 0"
		end
	end
end

function M.setup_autocmd(group_name, cb)
	M.cache.diagnostics = M.get_diagnostics()

	vim.api.nvim_create_autocmd({
		"DiagnosticChanged",
	}, {
		pattern = "*",
		callback = function ()
			if U.laststatus() == 3 then
				M.cache.diagnostics = M.get_diagnostics()
			end
			cb()
		end,
		group = group_name,
	})
end

return M
