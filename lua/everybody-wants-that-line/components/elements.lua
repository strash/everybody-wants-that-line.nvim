local C = require("everybody-wants-that-line.colors")
local UC = require("everybody-wants-that-line.utils.color-util")
local UU = require("everybody-wants-that-line.utils.util")

local M = {}

---@class elements
---@field arrow_down string `"↓"`
---@field arrow_left string `"←"`
---@field arrow_right string `"→"`
---@field arrow_up string `"↑"`
---@field bufmod_flag string `"%M"`
---@field column_idx string `"%c"`
---@field comma string `","`
---@field lines_of_code string `"%L"`
---@field percent string `"%%"`
---@field percentage_in_lines string `"%p"`
---@field space string `" "`
---@field spacer string `"%="`
---@field truncate string `"%<"`

---@type elements
M.el = {
	arrow_down = "↓",
	arrow_left = "←",
	arrow_right = "→",
	arrow_up = "↑",
	bufmod_flag = "%M",
	column_idx = "%c",
	comma = ",",
	lines_of_code = "%L",
	percent = "%%",
	percentage_in_lines = "%p",
	space = " ",
	spacer = "%=",
	truncate = "%<",
}

---@class element_cache
---@field col string
---@field col_nc string
---@field comma string
---@field comma_nc string
---@field ln string
---@field ln_nc string
---@field loc string
---@field loc_nc string
---@field separator string
---@field separator_nc string

---@type element_cache
M.cache = {
	col = "",
	col_nc = "",
	comma = "",
	comma_nc = "",
	ln = "",
	ln_nc = "",
	loc = "",
	loc_nc = "",
	separator = "",
	separator_nc = "",
}

---Returns separator
---@return string
function M.get_separator()
	if UU.laststatus() == 3 or UU.is_focused() then
		return M.cache.separator
	else
		return M.cache.separator_nc
	end
end

---Sets separator
---@param separator string
local function set_separator(separator)
	local text = M.el.space .. separator .. M.el.space
	M.cache.separator = UC.highlight_text(text, C.group_names.fg_20)
	M.cache.separator_nc = UC.highlight_text(text, C.group_names.fg_nc_20, true)
end

---Returns comma
---@return string
function M.get_comma()
	if UU.laststatus() == 3 or UU.is_focused() then
		return M.cache.comma
	else
		return M.cache.comma_nc
	end
end

---Sets comma
local function set_comma()
	M.cache.comma = UC.highlight_text(M.el.comma, C.group_names.fg_50)
	M.cache.comma_nc = UC.highlight_text(M.el.comma, C.group_names.fg_nc_50, true)
end

---Returns percentage through file in lines
---@return string
function M.get_ln()
	if UU.laststatus() == 3 or UU.is_focused() then
		return M.cache.ln
	else
		return M.cache.ln_nc
	end
end

---Sets percentage through file in lines
local function set_ln()
	local text = M.el.percentage_in_lines .. M.el.percent
	M.cache.ln = UC.highlight_text(M.el.arrow_down, C.group_names.fg_50) .. text
	M.cache.ln_nc = UC.highlight_text(M.el.arrow_down, C.group_names.fg_nc_50, true) .. text
end

---Returns column index
---@return string
function M.get_col()
	if UU.laststatus() == 3 or UU.is_focused() then
		return M.cache.col
	else
		return M.cache.col_nc
	end
end

---Sets column index
local function set_col()
	M.cache.col = UC.highlight_text(M.el.arrow_right, C.group_names.fg_50) .. M.el.column_idx
	M.cache.col_nc = UC.highlight_text(M.el.arrow_right, C.group_names.fg_nc_50, true) .. M.el.column_idx
end

---Returns lines of code
---@return string
function M.get_loc()
	if UU.laststatus() == 3 or UU.is_focused() then
		return M.cache.loc
	else
		return M.cache.loc_nc
	end
end

---Sets lines of code
local function set_loc()
	M.cache.loc = M.el.lines_of_code .. UC.highlight_text("LOC", C.group_names.fg_50) .. M.el.space
	M.cache.loc_nc = M.el.lines_of_code .. UC.highlight_text("LOC", C.group_names.fg_nc_50, true) .. M.el.space
end

---Init elements
---@param opts opts
function M.init(opts)
	set_separator(opts.separator)
	set_comma()
	set_ln()
	set_col()
	set_loc()
end

return M
