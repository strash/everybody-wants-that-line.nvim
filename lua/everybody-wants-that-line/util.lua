local M = {}

M.prefix = "EverybodyWantsThatLine"

--- fill string with value n times
function M.fill_string(s, v, n)
	return string.rep(v, n), s
end

--- linear interpolation
function M.lerp(v, a, b)
	if a and b then
		return (1.0 - v) * a + b * v
	else
		return b
	end
end

--- math round
function M.round(v)
	if tostring(v):find("%.") == nil then
		return v
	else
		local dec = tonumber(tostring(v):match("%.%d+"))
		if dec >= 0.5 then
			return math.ceil(v)
		else
			return math.floor(v)
		end
	end
end

--- check if a value exist in an enumerated table
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

--- get cterm for a highlight group
function M.cterm(v)
	local c = " "
	if v ~= nil and type(v) == "string" and #v > 0 then
		c = " cterm=" .. v .. " gui=" .. v .. " "
	end
	return c
end

--- format string
function M.pascalcase(s)
	local parts = {}
	for i in string.gmatch(s, "%w+") do
		table.insert(parts, i:sub(0, 1):upper() .. i:sub(2))
	end
	return table.concat(parts)
end

return M
