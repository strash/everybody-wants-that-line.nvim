local C = require("everybody-wants-that-line.colors")
local CE = require("everybody-wants-that-line.components.elements")
local UC = require("everybody-wants-that-line.utils.color-util")
local UU = require("everybody-wants-that-line.utils.util")

local M = {}

local cache = {
	bufmod_flag = ""
}

---Returns buffer modified flag
---@param opts_buffer opts_buffer
---@return string
function M.bufmod_flag(opts_buffer)
	if UU.laststatus() == 3 and cache.bufmod_flag ~= "" then
		return cache.bufmod_flag
	else
		cache.bufmod_flag = CE.el.space .. opts_buffer.prefix .. CE.el.bufmod_flag .. CE.el.space
		return cache.bufmod_flag
	end
end

---Returns buffer number
---@param opts_buffer opts_buffer
---@return string
function M.buff_nr(opts_buffer)
	local bufnr
	if UU.laststatus() == 3 then
		bufnr = tostring(vim.api.nvim_get_current_buf())
	else
		bufnr = UU.is_focused() and vim.g.actual_curbuf or tostring(vim.api.nvim_get_current_buf())
	end
	local buffer_zeroes = ""
	if opts_buffer.max_symbols > #bufnr then
		buffer_zeroes = string.rep(opts_buffer.symbol, opts_buffer.max_symbols - #bufnr)
	end
	buffer_zeroes = #buffer_zeroes > 0 and UC.highlight_text(buffer_zeroes, C.group_names.fg_30) or ""
	return buffer_zeroes .. UC.highlight_text(bufnr, C.group_names.fg_bold)
end

return M
