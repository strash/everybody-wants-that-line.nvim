local C = require("everybody-wants-that-line.colors")
local CU = require("everybody-wants-that-line.color-util")
local D = require("everybody-wants-that-line.diagnostics")
local S = require("everybody-wants-that-line.settings")
local G = require("everybody-wants-that-line.git")
local U = require("everybody-wants-that-line.util")

local M = {}

---Elements
---@type { [string]: string }
local el = {
	spacer = "%=",
	space = " ",
	eocg = "%*",
	percent = "%%",
	bufmod_flag = "%M",
	percentage_in_lines = "%p",
	column_idx = "%c",
	lines_of_code = "%L",
	truncate = "%<",
}

---Cache
---@type { [string]: string }
local cache = {
	separator = "",
	comma = "",
	bufmod_flag = "",
	ln = "",
	col = "",
	loc = "",
}

---Returns highlighted text
---@param text string
---@param group_name string
---@return string
function M.highlight_text(text, group_name)
	return CU.format_group_name(group_name) .. text .. el.eocg
end

---Returns `text` with spacers on each side
---@param text string
---@return string
function M.spaced_text(text)
	return el.spacer .. text .. el.spacer
end

---Returns space
---@return string
function M.space()
	return el.space
end

---Returns separator
---@return string
function M.separator()
	if U.laststatus() == 3 and cache.separator ~= "" then
		return cache.separator
	else
		cache.separator = CU.format_group_name(C.group_names.fg_20) .. el.space .. S.opt.separator .. el.space .. el.eocg
		return cache.separator
	end
end

---Returns comma
---@return string
function M.comma()
	if U.laststatus() == 3 and cache.comma ~= "" then
		return cache.comma
	else
		cache.comma = M.highlight_text(",", C.group_names.fg_50)
		return cache.comma
	end
end

---Returns buffer modified flag
---@return string
function M.bufmod_flag()
	if U.laststatus() == 3 and cache.bufmod_flag ~= "" then
		return cache.bufmod_flag
	else
		cache.bufmod_flag = el.space .. S.opt.buffer.prefix .. el.bufmod_flag .. el.space
		return cache.bufmod_flag
	end
end

---Returns buffer number
---@return string
function M.buff_nr()
	local laststatus = U.laststatus()
	local bufnr
	if laststatus == 3 then
		bufnr = tostring(vim.api.nvim_get_current_buf())
	else
		bufnr = U.is_focused() and vim.g.actual_curbuf or tostring(vim.api.nvim_get_current_buf())
	end
	local buffer_zeroes = ""
	if S.opt.buffer.max_symbols > #bufnr then
		buffer_zeroes = string.rep(S.opt.buffer.symbol, S.opt.buffer.max_symbols - #bufnr)
	end
	buffer_zeroes = #buffer_zeroes > 0 and M.highlight_text(buffer_zeroes, C.group_names.fg_30) or ""
	return buffer_zeroes .. M.highlight_text(bufnr, C.group_names.fg_bold)
end

---comment
---@param diagnostic_object diagnostic_object
---@param count_group_name string
---@param arrow_group_name string
---@param lnum_group_name string
---@return string
local function highlight_diagnostic(diagnostic_object, count_group_name, arrow_group_name, lnum_group_name)
	return table.concat({
		M.highlight_text(tostring(diagnostic_object.count), count_group_name),
		--el.space,
		M.highlight_text("↓", arrow_group_name),
		M.highlight_text(tostring(diagnostic_object.first_lnum), lnum_group_name)
	})
end

---Returns diagnostics
---@return string
function M.get_diagnostics()
	local diagnostics = D.get_diagnostics()
	local err, warn, hint, info = "0", "0", "0", "0"
	if diagnostics.error.count > 0 then
		err = highlight_diagnostic(diagnostics.error, C.group_names.fg_error_bold, C.group_names.fg_error_50, C.group_names.fg_error)
	end
	if diagnostics.warn.count > 0 then
		warn = highlight_diagnostic(diagnostics.warn, C.group_names.fg_warn_bold, C.group_names.fg_warn_50, C.group_names.fg_warn)
	end
	if diagnostics.hint.count > 0 then
		hint = highlight_diagnostic(diagnostics.hint, C.group_names.fg_hint_bold, C.group_names.fg_hint_50, C.group_names.fg_hint)
	end
	if diagnostics.info.count > 0 then
		info = highlight_diagnostic(diagnostics.info, C.group_names.fg_info_bold, C.group_names.fg_info_50, C.group_names.fg_info)
	end
	local comma_space = cache.comma .. el.space
	return err .. comma_space .. warn .. comma_space .. hint .. comma_space .. info
end

---Returns branch and status
---@return string
function M.branch_and_status()
	local insertions = G.cache.diff_info[1]
	local deletions = G.cache.diff_info[2]
	if #G.cache.branch == 0 then
		return ""
	end
	if #insertions > 0 then
		insertions = M.highlight_text(insertions, C.group_names.fg_diff_add_bold)
		insertions = insertions .. M.highlight_text("+", C.group_names.fg_diff_add_50) .. el.space
	end
	if #deletions > 0 then
		deletions = M.highlight_text(deletions, C.group_names.fg_diff_delete_bold)
		deletions = deletions .. M.highlight_text("-", C.group_names.fg_diff_delete_50) .. el.space
	end
	return table.concat({
		M.highlight_text(G.cache.branch, C.group_names.fg_60_bold),
		el.space,
		insertions,
		deletions,
	})
end

---Returns highlighted path
---@param path string
---@param tail string
---@return string
local function highlight_path(path, tail)
	local before_tail = path:sub(0, #path - #tail)
	before_tail = S.opt.filepath.shorten and vim.fn.pathshorten(before_tail) or before_tail
	local final = table.concat({
		M.highlight_text(before_tail, C.group_names.fg_60),
		M.highlight_text(tail, C.group_names.fg_bold),
	})
	return final
end

---Returns path to the file
---@return string
function M.file_path()
	---@type string
	local relative = vim.fn.bufname()
	---@type string
	local fullpath = vim.api.nvim_buf_get_name(0)
	if #relative == 0 or #fullpath == 0 then
		return "[No name]"
	end
	local tail = fullpath:match("[^/]+$")
	local path
	if S.opt.filepath.path == "tail" then
		path = M.highlight_text(tail, C.group_names.fg_bold)
	elseif S.opt.filepath.path == "relative" then
		path = highlight_path(relative, tail)
	else
		path = highlight_path(fullpath, tail)
	end
	return path
end

---Returns center block with branch, status and `text`
---@param text string
---@return string
function M.center_with_git_status(text)
	return M.spaced_text(M.branch_and_status() .. el.truncate .. text)
end

---Returns file size
---@return string
function M.file_size()
	local size = U.fsize()
	return size[1] .. M.highlight_text(size[2], C.group_names.fg_50)
end

---Returns percentage through file in lines
---@return string
function M.ln()
	if U.laststatus == 3 and cache.ln ~= "" then
		return cache.ln
	else
		cache.ln = M.highlight_text("↓", C.group_names.fg_50) .. el.percentage_in_lines .. el.percent
		return cache.ln
	end
end

---Returns column number
---@return string
function M.col()
	if U.laststatus == 3 and cache.col ~= "" then
		return cache.col
	else
		cache.col = M.highlight_text("→", C.group_names.fg_50) .. el.column_idx
		return cache.col
	end
end

---Returns lines of code
---@return string
function M.loc()
	if U.laststatus == 3 and el.loc ~= "" then
		return cache.loc
	else
		cache.loc = el.lines_of_code .. M.highlight_text("LOC", C.group_names.fg_50) .. el.space
		return cache.loc
	end
end

---Sets auto commands
---@param group_name string
---@param cb function
function M.setup_autocmd(group_name, cb)
	-- buffer modified flag
	vim.api.nvim_create_autocmd({
		"BufModifiedSet",
	}, {
		pattern = "*",
		callback = function()
			cb()
		end,
		group = group_name,
	})

	-- buffer number
	vim.api.nvim_create_autocmd({
		"BufAdd",
		"BufEnter",
	}, {
		pattern = "*",
		callback = function()
			cb()
		end,
		group = group_name,
	})
end

return M
