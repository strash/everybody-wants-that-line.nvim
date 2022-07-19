local CE = require("everybody-wants-that-line.components.elements")
local UU = require("everybody-wants-that-line.utils.util")

local M = {}

---@alias buffer_cache_bufnr { prefix: string, nr: string, bufnr: number }

---@class buffer_cache
---@field bufmod_flag string
---@field bufnrs { [number]: buffer_cache_bufnr }

---@type buffer_cache
M.cache = {
	bufmod_flag = "",
	bufnrs = {},
}

---Returns buffer modified flag `b+`
---@param opts_buffer opts_buffer
function M.set_bufmod_flag(opts_buffer)
	M.cache.bufmod_flag = opts_buffer.prefix .. CE.el.bufmod_flag
end

---Returns buffer number `{ prefix = "000", nr = "23", bufnr = 23 }`
---@param opts_buffer opts_buffer
---@return buffer_cache_bufnr
function M.get_buff_nr(opts_buffer)
	local bufnr = 0
	if UU.laststatus() == 3 then
		bufnr = vim.api.nvim_get_current_buf()
	else
		bufnr = UU.is_focused() and tonumber(vim.g.actual_curbuf) or vim.api.nvim_get_current_buf()
	end
	if M.cache.bufnrs[bufnr] ~= nil then
		return M.cache.bufnrs[bufnr]
	else
		---@type buffer_cache_bufnr
		local bufnr_item = {
			prefix = "",
			nr = tostring(bufnr),
			bufnr = bufnr,
		}
		if opts_buffer.max_symbols > #bufnr_item.nr then
			bufnr_item.prefix = string.rep(opts_buffer.symbol, opts_buffer.max_symbols - #bufnr_item.nr)
		end
		M.cache.bufnrs[bufnr] = bufnr_item
		return bufnr_item
	end
end

---Clear cache and init buffer
---@param opts opts
function M.init(opts)
	M.cache.bufmod_flag = ""
	M.cache.bufnrs = {}
	M.set_bufmod_flag(opts.buffer)
end

return M
