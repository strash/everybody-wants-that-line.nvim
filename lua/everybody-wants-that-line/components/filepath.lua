local M = {}

---@alias filepath_cache_path_part_split { path: string, shorten: string, filename: string }
---@alias filepath_cache_path_parts { relative: filepath_cache_path_part_split, full: filepath_cache_path_part_split }

---`filepath_cache`
---@type { [string]: filepath_cache_path_parts }
local cache = {}

---Returns splitted path and filename
---@param path string
---@return filepath_cache_path_part_split
local function split_path_and_filename(path)
	local f = path:match("[^/]+$")
	local p = path:sub(0, #path - #f)
	return { path = p, shorten = vim.fn.pathshorten(p), filename = f }
end

---Returns path to the file
---@return filepath_cache_path_parts
function M.get_filepath()
	---@type filepath_cache_path_parts
	local path_parts = {
		relative = {
			path = "",
			shorten = "",
			filename = "",
		},
		full = {
			path = "",
			shorten = "",
			filename = "",
		},
	}
	---@type string
	local fullpath = vim.api.nvim_buf_get_name(0)
	if #fullpath ~= 0 then
		if cache[fullpath] ~= nil then
			path_parts = cache[fullpath]
		else
			path_parts.full = split_path_and_filename(fullpath)
			---@type string
			local relative = vim.fn.bufname()
			if #relative ~= 0 then
				-- if buffer was opened with lsp go to ...
				local _, r_e = relative:find(vim.fn.getcwd(0), 0, true)
				if r_e ~= nil then
					relative = relative:sub(r_e + 2)
				end
				relative = "./" .. relative
				path_parts.relative = split_path_and_filename(relative)
			end
			cache[fullpath] = path_parts
		end
	end
	return path_parts
end

return M
