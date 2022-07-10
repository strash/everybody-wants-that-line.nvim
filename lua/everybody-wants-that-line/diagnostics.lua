local U = require("everybody-wants-that-line.util")

local M = {}

---@alias diagnostic_object { count: integer, first_lnum: integer }
---@alias diagnostics { error: diagnostic_object, warn: diagnostic_object, hint: diagnostic_object, info: diagnostic_object }

---Returns empty diagnostic object
---@return diagnostic_object `{ count: 0, first_lnum: 0 }`
local function get_empty_diagnostic_object()
	return { count = 0, first_lnum = 0 }
end

---Returns diagnostic object
---@param bufnr number
---@param severity any
---@return diagnostic_object
local function get_diagnostic_object(bufnr, severity)
	---@type diagnostic_object
	local diagnostic_object = {}
	---@type table[]
	local diagnostics = vim.diagnostic.get(bufnr, { severity = severity })
	diagnostic_object.count = #diagnostics
	diagnostic_object.first_lnum = diagnostic_object.count > 0 and diagnostics[1].lnum + 1 or 0
	return diagnostic_object
end

---Returns diagnostics object
---@return diagnostics
function M.get_diagnostics()
	---@type diagnostics
	local diagnostics = {}
	local laststatus = U.laststatus()
	local bufnr
	if laststatus == 3 then
		bufnr = vim.api.nvim_get_current_buf()
	else
		bufnr = U.is_focused() and tonumber(vim.g.actual_curbuf) or vim.api.nvim_get_current_buf()
	end
	local is_lsp_attached = #vim.lsp.get_active_clients() > 0
	if is_lsp_attached then
		diagnostics.error = get_diagnostic_object(bufnr, vim.diagnostic.severity.ERROR)
		diagnostics.warn = get_diagnostic_object(bufnr, vim.diagnostic.severity.WARN)
		diagnostics.hint = get_diagnostic_object(bufnr, vim.diagnostic.severity.HINT)
		diagnostics.info = get_diagnostic_object(bufnr, vim.diagnostic.severity.INFO)
	else
		diagnostics.error = get_empty_diagnostic_object()
		diagnostics.warn = get_empty_diagnostic_object()
		diagnostics.hint = get_empty_diagnostic_object()
		diagnostics.info = get_empty_diagnostic_object()
	end
	return diagnostics
end

---Sest auto commands
---@param group_name string
---@param cb function
function M.setup_autocmd(group_name, cb)
	vim.api.nvim_create_autocmd({
		"DiagnosticChanged",
	}, {
		pattern = "*",
		callback = function()
			cb()
		end,
		group = group_name,
	})
end

return M
