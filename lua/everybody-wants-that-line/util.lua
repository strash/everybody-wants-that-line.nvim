local settings = require("everybody-wants-that-line.settings")

local M = {}

M.get_formatted_buffer_number = function ()
	local buffer_number = tostring(vim.api.nvim_get_current_buf())
	local zeroes = ""
	if settings.buffer_number_symbol_count > #buffer_number then
		zeroes = string.rep("0", settings.buffer_number_symbol_count - #buffer_number)
	end
	return zeroes, buffer_number
end

return M
