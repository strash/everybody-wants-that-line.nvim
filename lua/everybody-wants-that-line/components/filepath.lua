local M = {}

---@alias splitted_path { path: string, shorten: string, filename: string }
---@alias path_parts { relative: splitted_path, full: splitted_path }

---@type { [string]: path_parts }
local cache = {}

---Returns splitted path and filename
---@param path string
---@return splitted_path
local function split_path_and_filename(path)
	local file = path:match("[^/]+$")
	local splitted_path = path:sub(0, #path - #file)
	return { path = splitted_path, shorten = vim.fn.pathshorten(splitted_path), filename = file }
end

---Returns path to the file
---@return path_parts
function M.filepath()
	---@type path_parts
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
			---@type string
			path_parts.full = split_path_and_filename(fullpath)
			local relative = vim.fn.bufname()
			if #relative ~= 0 then
				path_parts.relative = split_path_and_filename(relative)
			end
			cache[fullpath] = path_parts
		end
	end
	return path_parts
end

return M
