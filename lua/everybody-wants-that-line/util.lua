local M = {}

M.get_hl_group_color = function (group, color)
	local group_table = vim.api.nvim_get_hl_by_name(group, true)
	return string.format("#%06x", group_table[color])
end

return M
