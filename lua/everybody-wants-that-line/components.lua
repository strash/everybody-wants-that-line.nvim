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
	buff_nr = "",
	ln = "",
	col = "",
	loc = "",
}

-- highlighted text
function M:highlight_text(text, color_group_name)
	return CU.format_group_name(color_group_name) .. text .. self.eocg
end

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

-- branch and status
function M:branch_and_status()
	local insertions = G.cache.diff_info.insertions
	local deletions = G.cache.diff_info.deletions
	if #G.cache.branch == 0 then
		return self.path_to_the_file
	end
	if #insertions > 0 then
		insertions = self:highlight_text(insertions, C.color_group_names.fg_diff_add_bold)
		insertions = insertions .. self:highlight_text("+", C.color_group_names.fg_diff_add_50) .. self.space
	end
	if #deletions > 0 then
		deletions = self:highlight_text(deletions, C.color_group_names.fg_diff_delete_bold)
		deletions = deletions .. self:highlight_text("-", C.color_group_names.fg_diff_delete_50) .. self.space
	end
	return table.concat({
		self:highlight_text(G.cache.branch, C.color_group_names.fg_60_bold),
		self.space,
		insertions,
		deletions,
	})
end

-- center
function M:center()
	return self:branch_and_status() .. self.path_to_the_file
end

-- Fugitive
function M:fugitive()
	return self:branch_and_status() .. "Fugitive"
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

-- auto commands
function M.setup_autocmd(group_name, callback)
	M.cache.buff_mod_flag = M:buff_mod_flag()
	M.cache.separator = CU.format_group_name(C.color_group_names.fg_20) .. M.space .. S.separator .. M.space .. M.eocg
	M.cache.comma = M:highlight_text(",", C.color_group_names.fg_50)
	M.cache.ln = M:ln()
	M.cache.col = M:col()
	M.cache.loc = M:loc()

	-- buffer modified flag
	vim.api.nvim_create_autocmd({
		"BufModifiedSet",
	}, {
		pattern = "*",
		callback = function ()
			M.cache.buff_mod_flag = M:buff_mod_flag()
			callback()
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
			M.cache.buff_nr = M:buff_nr()
			callback()
		end,
		group = group_name,
	})
end

return M
