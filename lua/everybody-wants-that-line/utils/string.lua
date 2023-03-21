local String = {}

---Static. Returns joined string with delimiter.
---@generic T : string | string[]
---@param components T[] Table of strings and/or tables with strings
---@param with string Delimiter
---@return string
function String.join(components, with)
	if type(components) ~= "table" and type(components) ~= "string" then
		return ""
	end
	local result = ""
	for i, v in ipairs(components) do
		if type(v) ~= "string" and type(v) ~= "table" then
			v = tostring(v)
		end
		if #v ~= 0 then
			if i == 1 or #result == 0 then
				result = type(v) == "table" and table.concat(v) or v
			else
				result = result .. with .. (type(v) == "table" and table.concat(v) or v)
			end
		end
	end
	return result
end

---@alias cterm ""|"bold"

---Static. Returns cterm for a highlight group
---@param value cterm e.g. 'bold'
---@return string
function String.cterm(value)
	local c = " "
	if #value > 0 then
		c = " cterm=" .. value .. " gui=" .. value .. " "
	end
	return c
end

---Static. Returns string in PascalCase
---@param value string
---@return string
function String.pascalcase(value)
	local parts = {}
	for i in string.gmatch(value, "%w+") do
		table.insert(parts, i:sub(0, 1):upper() .. i:sub(2))
	end
	return table.concat(parts)
end

return String

