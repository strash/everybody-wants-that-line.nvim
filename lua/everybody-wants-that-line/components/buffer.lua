local C = require("everybody-wants-that-line.colors")
local CE = require("everybody-wants-that-line.components.elements")
local UC = require("everybody-wants-that-line.utils.color-util")
local UU = require("everybody-wants-that-line.utils.util")

local M = {}

---@alias buffer_cache_bufnr { prefix: string, nr: string, bufnr: number }

---@class buffer_cache
---@field bufprefix cache_item_variant
---@field bufnrs { [number]: buffer_cache_bufnr }

---@type buffer_cache
M.cache = {
	bufprefix = { n = "", nc = "" },
	bufnrs = {},
}

---Sets buffer prefix
---@param opts opts
local function set_buffer_prefix(opts)
	if #opts.buffer.prefix ~= 0 then
		M.cache.bufprefix.n = UC.highlight_text(opts.buffer.prefix .. CE.el.space, C.group_names.fg_60)
		M.cache.bufprefix.nc = UC.highlight_text(opts.buffer.prefix .. CE.el.space, C.group_names.fg_nc_60, true)
	end
end

---Returns buffer prefix
---@return string
function M.get_buffer_prefix()
	if UU.laststatus() == 3 or UU.is_focused() then
		return M.cache.bufprefix.n
	else
		return M.cache.bufprefix.nc
	end
end

---Returns buffer modified flag
---@return string
function M.get_buf_modflag()
	local bufnr = UU.get_bufnr()
	local is_modifiable = vim.api.nvim_buf_get_option(bufnr, "mod") --[[@as boolean]]
	---@type vim_buftype
	local buftype = vim.o.buftype
	local flag
	if is_modifiable then
		flag = CE.get_plus("100")
	elseif not is_modifiable then
		if buftype == "" then
			flag = " "
		else
			flag = CE.get_minus("100")
		end
	end
	return flag
end

---Returns buffer number `{ prefix = "000", nr = "23", bufnr = 23 }`
---@param opts_buffer opts_buffer
---@return buffer_cache_bufnr
function M.get_buf_nr(opts_buffer)
	local bufnr = UU.get_bufnr()
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
	set_buffer_prefix(opts)
end

return M
