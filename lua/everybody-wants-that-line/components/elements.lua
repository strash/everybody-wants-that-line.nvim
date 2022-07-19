local C = require("everybody-wants-that-line.colors")
local UC = require("everybody-wants-that-line.utils.color-util")

local M = {}

---@class elements
---@field spacer string `"%="`
---@field space string `" "`
---@field comma string `","`
---@field percent string `"%%"`
---@field bufmod_flag string `"%M"`
---@field percentage_in_lines string `"%p"`
---@field column_idx string `"%c"`
---@field lines_of_code string `"%L"`
---@field truncate string `"%<"`
---@field arrow_up string `"↑"`
---@field arrow_down string `"↓"`
---@field arrow_left string `"←"`
---@field arrow_right string `"→"`

---@type elements
M.el = {
	spacer = "%=",
	space = " ",
	comma = ",",
	percent = "%%",
	bufmod_flag = "%M",
	percentage_in_lines = "%p",
	column_idx = "%c",
	lines_of_code = "%L",
	truncate = "%<",
	arrow_up = "↑",
	arrow_down = "↓",
	arrow_left = "←",
	arrow_right = "→",
}

---@class element_cache
---@field separator string
---@field comma string
---@field ln string
---@field col string
---@field loc string

---@type element_cache
M.cache = {
	separator = "",
	comma = "",
	ln = "",
	col = "",
	loc = "",
}

---Sets separator
---@param separator string
local function set_separator(separator)
	M.cache.separator = UC.highlight_text(M.el.space .. separator .. M.el.space, C.group_names.fg_20)
end

---Sets comma
local function set_comma()
	M.cache.comma = UC.highlight_text(M.el.comma, C.group_names.fg_50)
end

---Sets percentage through file in lines
local function set_ln()
	M.cache.ln = UC.highlight_text(M.el.arrow_down, C.group_names.fg_50) .. M.el.percentage_in_lines .. M.el.percent
end

local function set_col()
	M.cache.col = UC.highlight_text(M.el.arrow_right, C.group_names.fg_50) .. M.el.column_idx
end

---Returns lines of code
local function set_loc()
	M.cache.loc = M.el.lines_of_code .. UC.highlight_text("LOC", C.group_names.fg_50) .. M.el.space
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
