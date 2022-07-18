local M = {}

---@alias buffer_symbol string Symbol before buffer number, e.g. "0000.". If you don't want additional symbols to be displayed, set `buffer.max_symbols = 0`.
---@alias buffer_max_symbols integer Maximum number of symbols including buffer number.
---@alias filepath_path
---| "tail" # File name only
---| "relative" # Relative to working directory
---| "full" # Full path to the file
---@alias filepath_shorten boolean If `true` the path will be shortened, e.g. "/a/b/c/filename.lua". It only works if `path` is "relative" or "full".
---@alias filesize_metric "decimal"|"binary"

---@alias opts_buffer { show: boolean, prefix: string, symbol: buffer_symbol, max_symbols: buffer_max_symbols }
---@alias opts_filepath { path: filepath_path, shorten: filepath_shorten }
---@alias opts_filesize { metric: filesize_metric }

---@class opts
---@field buffer opts_buffer
---@field filepath opts_filepath
---@field separator string
---@field filesize opts_filesize

---@type opts
M.opt = {
	buffer = {
		show = true,
		prefix = "b",
		symbol = "0",
		max_symbols = 5,
	},
	filepath = {
		path = "relative",
		shorten = false,
	},
	filesize = {
		metric = "decimal"
	},
	separator = "│",
}

---Check if path matches a filename
---@param path filepath_path
---@return filepath_path
local function check_filepath(path)
	if path == "tail" or path == "relative" or path == "full" then
		return path
	end
	return "relative"
end

---Check if metric matches filesize metric
---@param metric filesize_metric
---@return filesize_metric
local function check_filesize_metric(metric)
	if metric == "decimal" or metric == "binary" then
		return metric
	end
	return "decimal"
end

---Setup
---@param opt opts
function M.setup(opt)
	if opt ~= nil and type(opt) == "table" then
		for k, v in pairs(opt) do
			if type(v) == "table" then
				for vk, vv in pairs(v) do
					if M.opt[k][vk] ~= nil and type(M.opt[k][vk]) == type(vv) then
						if k == "filepath" and vk == "path" then
							M.opt[k][vk] = check_filepath(vv)
						elseif k == "filesize" and vk == "metric" then
							M.opt[k][vk] = check_filesize_metric(vv)
						else
							M.opt[k][vk] = vv
						end
					end
				end
			else
				if M.opt[k] ~= nil and type(M.opt[k]) == type(v) then
					M.opt[k] = v
				end
			end
		end
	end
end

return M
