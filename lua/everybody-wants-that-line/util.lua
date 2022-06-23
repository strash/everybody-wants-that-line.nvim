local settings = require("everybody-wants-that-line.settings")

local M = {}

function M.get_formatted_buffer_number()
	local buffer_number = tostring(vim.api.nvim_get_current_buf())
	local zeroes = ""
	if settings.buffer_number_symbol_count > #buffer_number then
		zeroes = string.rep("0", settings.buffer_number_symbol_count - #buffer_number)
	end
	return zeroes, buffer_number
end

function M.lerp(v, a, b)
	return (1.0 - v) * a + b * v
end

function M.cterm(v)
	local c = " "
	if v ~= nil and type(v) == "string" and #v > 0 then
		c = " cterm=" .. v .. " gui=" .. v .. " "
	end
	return c
end

function M.pascalcase(v)
	local parts = {}
	for i in string.gmatch(v, "%w+") do
		table.insert(parts, i:sub(0, 1):upper() .. i:sub(2))
	end
	return table.concat(parts)
end

return M
