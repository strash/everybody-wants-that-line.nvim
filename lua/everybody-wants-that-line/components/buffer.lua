local C = require("everybody-wants-that-line.colors")
local CE = require("everybody-wants-that-line.components.elements")
local UC = require("everybody-wants-that-line.utils.color")
local UU = require("everybody-wants-that-line.utils.util")

local M = {}

---@alias buffer_cache_bufnr { prefix: string, nr: string, bufnr: number, result: cache_item_variant }

---@class buffer_cache
---@field bufprefix cache_item_variant
---@field bufnrs { [number]: buffer_cache_bufnr }

---@type buffer_cache
local cache = {
	bufprefix = { n = "", nc = "" },
	bufnrs = {},
}

---Sets buffer prefix
---@param opts opts
local function set_buffer_symbol(opts)
	if #opts.buffer.prefix ~= 0 then
		cache.bufprefix.n = UC.highlight_text(opts.buffer.prefix .. CE.el.space, C.group_names.fg_60, true)
		cache.bufprefix.nc = UC.highlight_text(opts.buffer.prefix .. CE.el.space, C.group_names.fg_nc_60, true)
	end
end

---Returns buffer prefix
---@return string
function M.get_buffer_symbol()
	return UU.get_cache_item_variant(cache.bufprefix)
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

---Returns buffer number `{ prefix = "000", nr = "23", bufnr = 23, result = { n = "%#group_name#23%*", nc = "%#group_name_nc#23%*" }`
---@param opts_buffer opts_buffer
---@return buffer_cache_bufnr
function M.get_buf_nr(opts_buffer)
	local bufnr = UU.get_bufnr()
	if cache.bufnrs[bufnr] ~= nil then
		return cache.bufnrs[bufnr]
	else
		local nr, prefix = tostring(bufnr), ""
		---@type buffer_cache_bufnr
		local bufnr_item = {
			prefix = prefix,
			nr = nr,
			bufnr = bufnr,
			result = {
				n = "",
				nc = ""
			},
		}
		if opts_buffer.max_symbols > #nr then
			bufnr_item.prefix = string.rep(opts_buffer.symbol, opts_buffer.max_symbols - #nr)
			prefix = UC.highlight_text(bufnr_item.prefix, C.group_names.fg_30)
		end
		bufnr_item.result = {
			n = prefix .. UC.highlight_text(nr, C.group_names.fg_bold, true),
			nc = prefix .. UC.highlight_text(nr, C.group_names.fg_nc_bold, true)
		}
		cache.bufnrs[bufnr] = bufnr_item
		return bufnr_item
	end
end

---Clear cache and init buffer
---@param opts opts
function M.init(opts)
	set_buffer_symbol(opts)
end

return M
