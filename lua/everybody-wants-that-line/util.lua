local M = {}

M.prefix = "EverybodyWantsThatLine"
M.wintype = {
	UNKNOWN = 0,
	NORMAL = 1,
	LOCLIST = 2,
	QUICKFIX = 3,
	PREVIEW = 4,
	HELP = 5,
	NVIMTREE = 6,
	PACKER = 7,
	FUGITIVE = 8,
	TELESCOPE = 9,
}

---Returns filled string with value n times and original value
---Example:
---<pre>
---fill_string("1", "0", 4)
---returns "00001", "1"
---</pre>
---@param s string what to fill
---@param v string value fill with
---@param n integer n times
---@return string \ filled value
---@return string \ original value
function M.fill_string(s, v, n)
	return string.rep(v, n), s
end

---Returns linearly interpolated number
---@param v number from 0.0 to 1.0
---@param a number
---@param b number
---@return number
function M.lerp(v, a, b)
	if a and b then
		return (1.0 - v) * a + b * v
	else
		return b
	end
end

---Returns rounded integer from `v`
---@param v number
---@return integer
function M.round(v)
	if tostring(v):find("%.") == nil then
		return math.floor(v)
	else
		local dec = tonumber(tostring(v):match("%.%d+"))
		if dec >= 0.5 then
			return math.ceil(v)
		else
			return math.floor(v)
		end
	end
end

---Returns wrapped integer `v` between `min` and `max`
---@param v integer
---@param min integer
---@param max integer
---@return any
function M.wrapi(v, min, max)
	local range = max - min
	return range == 0 and min or min + ((((v - min) % range) + range) % range)
end

---Check if a value exist in an enumerated table
---@param t table
---@param v any
---@return boolean
function M.is_value_exist(t, v)
	local is_value_exist = false
	for _, _v in ipairs(t) do
		if _v == v then
			is_value_exist = true
			break
		end
	end
	return is_value_exist
end

---Get cterm for a highlight group
---@param v string e.g. 'bold'
---@return string
function M.cterm(v)
	local c = " "
	if v ~= nil and type(v) == "string" and #v > 0 then
		c = " cterm=" .. v .. " gui=" .. v .. " "
	end
	return c
end

---Format string to PascalCase
---@param s string
---@return string
function M.pascalcase(s)
	local parts = {}
	for i in string.gmatch(s, "%w+") do
		table.insert(parts, i:sub(0, 1):upper() .. i:sub(2))
	end
	return table.concat(parts)
end

---Check if statusline on focused window
---@return boolean
function M.is_focused()
  return tonumber(vim.g.actual_curwin) == vim.api.nvim_get_current_win()
end

---Get laststatus
---@return number
function M.laststatus()
	return vim.o.laststatus
end

---Returns window type:
--- - `UNKNOWN`
--- - `NORMAL`,
--- - `LOCLIST`,
--- - `QUICKFIX`,
--- - `PREVIEW`,
--- - `HELP`,
--- - `NVIMTREE`,
--- - `PACKER`,
--- - `FUGITIVE`,
--- - `TELESCOPE`,
---@return integer enum 
function M.get_wintype()
	local buff_name = vim.api.nvim_buf_get_name(0)
	local wintype = vim.fn.win_gettype() -- empty (normal or NvimTree), loclist, popup, preview, quickfix, unknown
	local buftype = vim.o.buftype -- help, quickfix, terminal, prompt, nofile (NvimTree)
	if wintype == "" then
		if wintype == "" and buftype == "nofile" then
			if buff_name:find("NvimTree_1$") ~= nil then
				return M.wintype.NVIMTREE
			elseif buff_name:find("%[packer%]") ~= nil then
				return M.wintype.PACKER
			else
				return M.wintype.UNKNOWN
			end
		elseif buftype == "nowrite" and buff_name:find(".git/index$") ~= nil then
			return M.wintype.FUGITIVE
		elseif buftype == "help" then
			return M.wintype.HELP
		elseif buftype ~= "nofile" and buff_name:find("NvimTree_1$") == nil then
			return M.wintype.NORMAL
		end
	elseif wintype == "popup" and buftype == "prompt" then
		return M.wintype.TELESCOPE
	elseif wintype == "loclist" then
		return M.wintype.LOCLIST
	elseif wintype == "quickfix" then
		return M.wintype.QUICKFIX
	elseif wintype == "preview" then
		return M.wintype.PREVIEW
	end
	return M.wintype.UNKNOWN
end

return M
