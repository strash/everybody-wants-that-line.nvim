local C = require("everybody-wants-that-line.colors")
local UC = require("everybody-wants-that-line.utils.color-util")
local UU = require("everybody-wants-that-line.utils.util")

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

---@alias cache_item_variant { n: string, nc: string }

---@class element_cache
---@field col cache_item_variant
---@field comma cache_item_variant
---@field ln cache_item_variant
---@field loc cache_item_variant
---@field minus cache_item_variant
---@field minus_50 cache_item_variant
---@field plus cache_item_variant
---@field plus_50 cache_item_variant
---@field separator cache_item_variant

---@type element_cache
M.cache = {
	col = { n = "", nc = "" },
	comma = { n = "", nc = "" },
	ln = { n = "", nc = "" },
	loc = { n = "", nc = "" },
	minus = { n = "", nc = "" },
	minus_50 = { n = "", nc = "" },
	plus = { n = "", nc = "" },
	plus_50 = { n = "", nc = "" },
	separator = { n = "", nc = "" },
}

---Sets `"+"` and `"-"`
local function set_signs()
	M.cache.minus.n = UC.highlight_text(M.el.minus, C.group_names.fg_diff_delete)
	M.cache.minus.nc = UC.highlight_text(M.el.minus, C.group_names.fg_nc_diff_delete, true)
	M.cache.minus_50.n = UC.highlight_text(M.el.minus, C.group_names.fg_diff_delete_50)
	M.cache.minus_50.nc = UC.highlight_text(M.el.minus, C.group_names.fg_nc_diff_delete_50, true)
	M.cache.plus.n = UC.highlight_text(M.el.plus, C.group_names.fg_diff_add)
	M.cache.plus.nc = UC.highlight_text(M.el.plus, C.group_names.fg_nc_diff_add, true)
	M.cache.plus_50.n = UC.highlight_text(M.el.plus, C.group_names.fg_diff_add_50)
	M.cache.plus_50.nc = UC.highlight_text(M.el.plus, C.group_names.fg_nc_diff_add_50, true)
end

---Sets separator
---@param separator string
local function set_separator(separator)
	local text = M.el.space .. separator .. M.el.space
	M.cache.separator.n = UC.highlight_text(text, C.group_names.fg_20)
	M.cache.separator.nc = UC.highlight_text(text, C.group_names.fg_nc_20, true)
end

---Sets comma
local function set_comma()
	M.cache.comma.n = UC.highlight_text(M.el.comma, C.group_names.fg_50)
	M.cache.comma.nc = UC.highlight_text(M.el.comma, C.group_names.fg_nc_50, true)
end

---Sets percentage through file in lines
local function set_ln()
	local text = M.el.percentage_in_lines .. M.el.percent
	M.cache.ln.n = UC.highlight_text(M.el.arrow_down, C.group_names.fg_50) .. text
	M.cache.ln.nc = UC.highlight_text(M.el.arrow_down, C.group_names.fg_nc_50, true) .. text
end

---Sets column index
local function set_col()
	M.cache.col.n = UC.highlight_text(M.el.arrow_right, C.group_names.fg_50) .. M.el.column_idx
	M.cache.col.nc = UC.highlight_text(M.el.arrow_right, C.group_names.fg_nc_50, true) .. M.el.column_idx
end

---Sets lines of code
local function set_loc()
	M.cache.loc.n = M.el.lines_of_code .. UC.highlight_text("LOC", C.group_names.fg_50) .. M.el.space
	M.cache.loc.nc = M.el.lines_of_code .. UC.highlight_text("LOC", C.group_names.fg_nc_50, true) .. M.el.space
end

---@alias sign_opacity "50"|"100"

---Returns plus `"+"`
---@param opacity sign_opacity
---@return string
function M.get_plus(opacity)
	if UU.laststatus() == 3 or UU.is_focused() then
		return opacity == "100" and M.cache.plus.n or M.cache.plus_50.n
	else
		return opacity == "100" and M.cache.plus.nc or M.cache.plus_50.nc
	end
end

---Returns minus `"-"`
---@param opacity sign_opacity
---@return string
function M.get_minus(opacity)
	if UU.laststatus() == 3 or UU.is_focused() then
		return opacity == "100" and M.cache.minus.n or M.cache.minus_50.n
	else
		return opacity == "100" and M.cache.minus.nc or M.cache.minus_50.nc
	end
end

---Returns separator `" | "`
---@return string
function M.get_separator()
	if UU.laststatus() == 3 or UU.is_focused() then
		return M.cache.separator.n
	else
		return M.cache.separator.nc
	end
end

---Returns comma `","`
---@return string
function M.get_comma()
	if UU.laststatus() == 3 or UU.is_focused() then
		return M.cache.comma.n
	else
		return M.cache.comma.nc
	end
end

---Returns percentage through file in lines
---@return string
function M.get_ln()
	if UU.laststatus() == 3 or UU.is_focused() then
		return M.cache.ln.n
	else
		return M.cache.ln.nc
	end
end

---Returns column index
---@return string
function M.get_col()
	if UU.laststatus() == 3 or UU.is_focused() then
		return M.cache.col.n
	else
		return M.cache.col.nc
	end
end

---Returns lines of code
---@return string
function M.get_loc()
	if UU.laststatus() == 3 or UU.is_focused() then
		return M.cache.loc.n
	else
		return M.cache.loc.nc
	end
end

---Init elements
---@param opts opts
function M.init(opts)
	set_signs()
	set_separator(opts.separator)
	set_comma()
	set_ln()
	set_col()
	set_loc()
end

return M
