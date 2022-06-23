local M = {}

M.prefix = "EverybodyWantsThatLine"

--- fill string with value n times
function M.fill_string(s, v, n)
	return string.rep(v, n), s
end

--- linear interpolation
function M.lerp(v, a, b)
	return (1.0 - v) * a + b * v
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
