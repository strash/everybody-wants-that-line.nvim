local colors = require("everybody-wants-that-line.colors")
local settings = require("everybody-wants-that-line.settings")
local gitbranch = require("everybody-wants-that-line.gitbranch")
local util = require("everybody-wants-that-line.util")

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
	loc = "%L",
}

-- separator
M.separator = (function ()
	local separator_color_group = colors.get_statusline_group(colors.color_group_names.fg_20)
	return separator_color_group .. M.space .. settings.separator .. M.space .. M.eocg
end)()

-- highlighted text with secondary style
function M:get_highlighted_text(text, color_group_name)
	local cg = colors.get_statusline_group(color_group_name)
	return cg .. text .. self.eocg
end

-- text with spacers
function M:get_simple_line(text)
	return self.spacer .. text .. self.spacer
end

-- buffer modified flag
function M:left_side_buff_flag()
	return self.space .. "b" .. self.buffer_modified_flag .. self.space
end

-- buffer number
function M:get_buffer_number()
	local buffer_zeroes, buffer_number = util.get_formatted_buffer_number()
	local zeroes = ""
	if #buffer_zeroes > 0 then
		zeroes = self:get_highlighted_text(buffer_zeroes, colors.color_group_names.fg_40)
	end
	return zeroes .. self:get_highlighted_text(buffer_number, colors.color_group_names.fg_bold)
end

-- center
function M:center()
	local branch_name = gitbranch.get_git_branch()
	if #branch_name == 0 then
		return self.path_to_the_file
	end
	return self:get_highlighted_text(branch_name, colors.color_group_names.fg_60_bold) .. self.space .. self.path_to_the_file
end

-- percentage through file in lines
function M:right_side_ln()
	return self:get_highlighted_text("↓", colors.color_group_names.fg_40) .. self.space .. self.percentage_in_lines .. self.percent
end

-- column number
function M:right_side_col()
	return self:get_highlighted_text("→", colors.color_group_names.fg_40) .. self.space .. self.column_idx
end

-- lines of code
function M:right_side_loc()
	return self.loc .. self.space .. self:get_highlighted_text("LOC", colors.color_group_names.fg_40) .. self.space
end

return M
