local M = {}

M.prefix = "EverybodyWantsThatLine"

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

return M
