local C = require("everybody-wants-that-line.colors")
local Window = require("everybody-wants-that-line.utils.window")

local M = {}

---@class elements
---@field arrow_down string `"↓"`
---@field arrow_left string `"←"`
---@field arrow_right string `"→"`
---@field arrow_up string `"↑"`
---@field column_idx string `"%c"`
---@field comma string `","`
---@field lines_of_code string `"%L"`
---@field minus string `"-"`
---@field percent string `"%%"`
---@field percentage_in_lines string `"%p"`
---@field plus string `"+"`
---@field space string `" "`
---@field spacer string `"%="`
---@field truncate string `"%<"`

---@type elements
M.el = {
	arrow_down = "↓",
	arrow_left = "←",
	arrow_right = "→",
	arrow_up = "↑",
	column_idx = "%c",
	comma = ",",
	lines_of_code = "%L",
	minus = "-",
	percent = "%%",
	percentage_in_lines = "%p",
	plus = "+",
	space = " ",
	spacer = "%=",
	truncate = "%<",
}

---Returns string with spaces on each side
---@param value string
---@return string
function M.with_offset(value)
	if type(value) ~= "string" then
		value = tostring(value)
	end
	return M.el.space .. value .. M.el.space
end

---Returns string with spacers on each side
---@generic T : string | string[]
---@param value T Table of strings or tables with strings
---@return string
function M.spaced_text(value)
	if type(value) ~= "table" and type(value) ~= "string" then
		value = tostring(value)
	end
	return M.el.spacer .. M.with_offset(type(value) == "table" and table.concat(value) or value) .. M.el.spacer
end

---@alias sign_opacity "50"|"100"

---Returns highlighted plus `"+"`
---@param opacity sign_opacity
---@return string
function M.get_plus(opacity)
	local is_focused = Window.is_focused()
	---@type string
	local group_name
	if opacity == "100" then
		group_name = C.group_names[is_focused and "fg_diff_add" or "fg_nc_diff_add"]
	else
		group_name = C.group_names[is_focused and "fg_diff_add_50" or "fg_nc_diff_add_50"]
	end
	return C.highlight_text(M.el.plus, group_name, not is_focused)
end

---Returns highlighted minus `"-"`
---@param opacity sign_opacity
---@return string
function M.get_minus(opacity)
	local is_focused = Window.is_focused()
	---@type string
	local group_name
	if opacity == "100" then
		group_name = C.group_names[is_focused and "fg_diff_delete" or "fg_nc_diff_delete"]
	else
		group_name = C.group_names[is_focused and "fg_diff_delete_50" or "fg_nc_diff_delete_50"]
	end
	return C.highlight_text(M.el.minus, group_name, not is_focused)
end

---Returns highlighted separator `"|"`
---@param separator string
---@return string
function M.get_separator(separator)
	local is_focused = Window.is_focused()
	return C.highlight_text(tostring(separator), C.group_names[is_focused and "fg_20" or "fg_nc_20"], not is_focused)
end

---Returns highlighted comma `","`
---@return string
function M.get_comma()
	local is_focused = Window.is_focused()
	return C.highlight_text(M.el.comma, C.group_names[is_focused and "fg_50" or "fg_nc_50"], not is_focused)
end

---Returns highlighted percentage through file in lines
---@return string
function M.get_ln()
	local is_focused = Window.is_focused()
	local text = M.el.percentage_in_lines .. M.el.percent
	return C.highlight_text(M.el.arrow_down, C.group_names[is_focused and "fg_50" or "fg_nc_50"], not is_focused) .. text
end

---Returns highlighted column index
---@return string
function M.get_col()
	local is_focused = Window.is_focused()
	return C.highlight_text(M.el.arrow_right, C.group_names[is_focused and "fg_50" or "fg_nc_50"], not is_focused) .. M.el.column_idx
end

---Returns highlighted lines of code
---@return string
function M.get_loc()
	local is_focused = Window.is_focused()
	return M.el.lines_of_code .. C.highlight_text("LOC", C.group_names[is_focused and "fg_50" or "fg_nc_50"], not is_focused)
end

return M
