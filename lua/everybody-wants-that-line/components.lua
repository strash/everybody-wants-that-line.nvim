local C = require("everybody-wants-that-line.colors")
local CU = require("everybody-wants-that-line.color-util")
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

M.cache = {
	separator = "",
	comma = "",
	buff_mod_flag = "",
	ln = "",
	col = "",
	loc = "",
}

-- highlighted text
function M.highlight_text(text, color_group_name)
	return CU.format_group_name(color_group_name) .. text .. M.eocg
end

-- text with spacers
function M.spaced_text(text)
	return M.spacer .. text .. M.spacer
end

---Get separator
---@return string
function M.separator()
	if U.laststatus() == 3 and M.cache.separator ~= "" then
		return M.cache.separator
	else
		return CU.format_group_name(C.color_group_names.fg_20) .. M.space .. S.separator .. M.space .. M.eocg
	end
end

---Get comma
---@return string
function M.comma()
	if U.laststatus() == 3 and M.cache.comma ~= "" then
		return M.cache.comma
	else
		return M.highlight_text(",", C.color_group_names.fg_50)
	end
end

-- buffer modified flag
function M.buff_mod_flag()
	if U.laststatus() == 3 and M.cache.buff_mod_flag ~= "" then
		return M.cache.buff_mod_flag
	else
		return M.space .. "b" .. M.buffer_modified_flag .. M.space
	end
end

-- buffer number
function M.buff_nr()
	local laststatus = U.laststatus()
	local bufnr
	if laststatus == 3 then
		bufnr = tostring(vim.api.nvim_get_current_buf())
	else
		bufnr = U.is_focused() and vim.g.actual_curbuf or tostring(vim.api.nvim_get_current_buf())
	end
	local buffer_zeroes, buffer_number = "", ""
	if S.buffer.max_symbols > #bufnr then
		buffer_zeroes, buffer_number = U.fill_string(bufnr, S.buffer.symbol, S.buffer.max_symbols - #bufnr)
	end
	local zeroes = ""
	if #buffer_zeroes > 0 then
		zeroes = M.highlight_text(buffer_zeroes, C.color_group_names.fg_30)
	end
	return zeroes .. M.highlight_text(buffer_number, C.color_group_names.fg_bold)
end

-- branch and status
function M.branch_and_status()
	local insertions = G.cache.diff_info.insertions
	local deletions = G.cache.diff_info.deletions
	if #G.cache.branch == 0 then
		return M.path_to_the_file
	end
	if #insertions > 0 then
		insertions = M.highlight_text(insertions, C.color_group_names.fg_diff_add_bold)
		insertions = insertions .. M.highlight_text("+", C.color_group_names.fg_diff_add_50) .. M.space
	end
	if #deletions > 0 then
		deletions = M.highlight_text(deletions, C.color_group_names.fg_diff_delete_bold)
		deletions = deletions .. M.highlight_text("-", C.color_group_names.fg_diff_delete_50) .. M.space
	end
	return table.concat({
		M.highlight_text(G.cache.branch, C.color_group_names.fg_60_bold),
		M.space,
		insertions,
		deletions,
	})
end

-- center
function M.center()
	return M.branch_and_status() .. M.path_to_the_file
end

-- Fugitive
function M.fugitive()
	return M.branch_and_status() .. "Fugitive"
end

-- percentage through file in lines
function M.ln()
	if U.laststatus == 3 and M.cache.ln ~= "" then
		return M.cache.ln
	else
		return M.highlight_text("↓", C.color_group_names.fg_50) .. M.percentage_in_lines .. M.percent
	end
end

-- column number
function M.col()
	if U.laststatus == 3 and M.cache.col ~= "" then
		return M.cache.col
	else
		return M.highlight_text("→", C.color_group_names.fg_50) .. M.column_idx
	end
end

-- lines of code
function M.loc()
	if U.laststatus == 3 and M.cache.loc ~= "" then
		return M.cache.loc
	else
		return M.lines_of_code .. M.highlight_text("LOC", C.color_group_names.fg_50) .. M.space
	end
end

-- auto commands
function M.setup_autocmd(group_name, cb)
	M.cache.buff_mod_flag = M.buff_mod_flag()
	M.cache.separator = M.separator()
	M.cache.comma = M.comma()
	M.cache.ln = M.ln()
	M.cache.col = M.col()
	M.cache.loc = M.loc()

	-- buffer modified flag
	vim.api.nvim_create_autocmd({
		"BufModifiedSet",
	}, {
		pattern = "*",
		callback = function ()
			if U.laststatus() == 3 then
				M.cache.buff_mod_flag = M.buff_mod_flag()
			end
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
		callback = function ()
			cb()
		end,
		group = group_name,
	})
end

return M
