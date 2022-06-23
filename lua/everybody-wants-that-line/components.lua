local C = require("everybody-wants-that-line.colors")
local S = require("everybody-wants-that-line.settings")
local G = require("everybody-wants-that-line.git")
local U = require("everybody-wants-that-line.util")

-- components
local M = {
	spacer = "%=",
	space = " ",
	eocg = "%*",
	percent = "%%",
	buffer_modified_flag = "%M",
	path_to_the_file = "%f",
	percentage_in_lines = "%p",
	column_idx = "%c",
	lines_of_code = "%L",
}

-- separator
M.separator = (function()
	local separator_color_group = C.get_statusline_group(C.color_group_names.fg_20)
	return separator_color_group .. M.space .. S.separator .. M.space .. M.eocg
end)()

-- highlighted text
function M:highlight_text(text, color_group_name)
	local cg = C.get_statusline_group(color_group_name)
	return cg .. text .. self.eocg
end

M.comma = (function()
	return M:highlight_text(",", C.color_group_names.fg_50)
end)()

-- text with spacers
function M:spaced_text(text)
	return self.spacer .. text .. self.spacer
end

-- buffer modified flag
function M:buff_mod_flag()
	return self.space .. "b" .. self.buffer_modified_flag .. self.space
end

-- buffer number
function M:buff_nr()
	local buffnr = tostring(vim.api.nvim_get_current_buf())
	local buffer_zeroes, buffer_number = "", ""
	if S.buffer.max_symbols > #buffnr then
		buffer_zeroes, buffer_number = U.fill_string(buffnr, S.buffer.symbol, S.buffer.max_symbols - #buffnr)
	end
	local zeroes = ""
	if #buffer_zeroes > 0 then
		zeroes = self:highlight_text(buffer_zeroes, C.color_group_names.fg_30)
	end
	return zeroes .. self:highlight_text(buffer_number, C.color_group_names.fg_bold)
end

-- center
function M:center()
	local branch_name = G.get_git_branch()
	local ins, del = G.get_diff_info()
	if #branch_name == 0 then
		return self.path_to_the_file
	end
	if #ins > 0 then
		ins = self:highlight_text(ins, C.color_group_names.fg_add)
		ins = ins .. self:highlight_text("+", C.color_group_names.fg_add_50)
		if #del > 0 then
			ins = ins .. self.space
		end
	end
	if #del > 0 then
		del = self:highlight_text(del, C.color_group_names.fg_remove)
		del = del .. self:highlight_text("-", C.color_group_names.fg_remove_50) .. self.space
	end
	return table.concat({
		self:highlight_text(branch_name, C.color_group_names.fg_60_bold),
		self.space,
		ins,
		del,
		self.path_to_the_file
	})
end

-- percentage through file in lines
function M:ln()
	return self:highlight_text("↓", C.color_group_names.fg_50) .. self.percentage_in_lines .. self.percent
end

-- column number
function M:col()
	return self:highlight_text("→", C.color_group_names.fg_50) .. self.column_idx
end

-- lines of code
function M:loc()
	return self.lines_of_code .. self:highlight_text("LOC", C.color_group_names.fg_50) .. self.space
end

return M
