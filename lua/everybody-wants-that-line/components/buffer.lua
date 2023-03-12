local C = require("everybody-wants-that-line.colors")
local CE = require("everybody-wants-that-line.components.elements")
local UU = require("everybody-wants-that-line.utils.util")

local M = {}

---Returns buffer prefix
---@param buffer_prefix string
---@return string
function M.get_buffer_symbol(buffer_prefix)
	local is_focused = UU.is_focused()
	buffer_prefix = tostring(buffer_prefix)
	if #buffer_prefix ~= 0 then
		return C.highlight_text(buffer_prefix .. CE.el.space, C.group_names[is_focused and "fg_60" or "fg_nc_60"],
			not is_focused)
	end
	return ""
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

---@alias buffer_bufnr { prefix: string, nr: string, bufnr: number, result: string }

---Returns buffer number `{ prefix = "000", nr = "23", bufnr = 23, result = "%#group_name#23%*"`
---@param opts_buffer opts_buffer
---@return buffer_bufnr
function M.get_buf_nr(opts_buffer)
	local bufnr = UU.get_bufnr()
	local is_focused = UU.is_focused()
	local nr, prefix = tostring(bufnr), ""
	---@type buffer_bufnr
	local bufnr_item = {
		prefix = prefix,
		nr = nr,
		bufnr = bufnr,
		result = ""
	}
	if tonumber(opts_buffer.max_symbols) > #nr then
		bufnr_item.prefix = string.rep(tostring(opts_buffer.symbol):sub(0, 2), tonumber(opts_buffer.max_symbols) - #nr)
		prefix = C.highlight_text(bufnr_item.prefix, C.group_names.fg_30)
	end
	bufnr_item.result = prefix .. C.highlight_text(nr, C.group_names[is_focused and "fg_bold" or "fg_nc_bold"], not is_focused)
	return bufnr_item
end

return M
