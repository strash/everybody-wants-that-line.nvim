local C = require("everybody-wants-that-line.colors")
local UC = require("everybody-wants-that-line.utils.color-util")
local UU = require("everybody-wants-that-line.utils.util")

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
}

---@class el_cache
---@field separator string
---@field comma string
---@field ln string
---@field col string
---@field loc string

---@type el_cache
local cache = {
	separator = "",
	comma = "",
	ln = "",
	col = "",
	loc = "",
}

---Returns separator
---@param separator string
---@return string
function M.separator(separator)
	if UU.laststatus() == 3 and cache.separator ~= "" then
		return cache.separator
	else
		cache.separator = UC.highlight_text(M.el.space .. separator .. M.el.space, C.group_names.fg_20)
		return cache.separator
	end
end

---Returns comma
---@return string
function M.comma()
	if UU.laststatus() == 3 and cache.comma ~= "" then
		return cache.comma
	else
		cache.comma = UC.highlight_text(M.el.comma, C.group_names.fg_50)
		return cache.comma
	end
end

---Returns percentage through file in lines
---@return string
function M.ln()
	if UU.laststatus == 3 and cache.ln ~= "" then
		return cache.ln
	else
		cache.ln = UC.highlight_text("↓", C.group_names.fg_50) .. M.el.percentage_in_lines .. M.el.percent
		return cache.ln
	end
end

---Returns column number
---@return string
function M.col()
	if UU.laststatus == 3 and cache.col ~= "" then
		return cache.col
	else
		cache.col = UC.highlight_text("→", C.group_names.fg_50) .. M.el.column_idx
		return cache.col
	end
end

---Returns lines of code
---@return string
function M.loc()
	if UU.laststatus == 3 and cache.loc ~= "" then
		return cache.loc
	else
		cache.loc = M.el.lines_of_code .. UC.highlight_text("LOC", C.group_names.fg_50) .. M.el.space
		return cache.loc
	end
end

return M
