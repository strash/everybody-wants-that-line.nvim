local M = {}


-- BUFFER

---@class opts_buffer
---@field enabled boolean Enable or disable component.
---@field prefix string
---@field symbol string Symbol before buffer number, e.g. "0000.". If you don't want additional symbols to be displayed, set `buffer.max_symbols = 0`.
---@field max_symbols integer Maximum number of symbols including buffer number.


-- DIAGNOSTICS

---@class opts_diagnostics
---@field enabled boolean Enable or disable component.


-- QUICKFIX LIST

---@class opts_quickfixlist
---@field enabled boolean Enable or disable component.


-- GIT STATUS

---@class opts_gitstatus
---@field enabled boolean Enable or disable component.


-- FILE PATH

---@alias filepath_path
---| '"tail"' # File name only
---| '"relative"' # Relative to working directory
---| '"full"' # Full path to the file

---@class opts_filepath
---@field enabled boolean Enable or disable component.
---@field path filepath_path Size of the path.
---@field shorten boolean If `true` the path will be shortened, e.g. "/a/b/c/filename.lua". It only works if `path` is "relative" or "full".


-- FILE SIZE

---@alias filesize_metric
---| '"decimal"' # 1000 bytes == 1 kilobyte
---| '"binary"' # 1024 bytes == 1 kibibyte

---@class opts_filesize
---@field enabled boolean Enable or disable component.
---@field metric filesize_metric Filesize metric.


-- RULLER

---@class opts_ruller
---@field enabled boolean Enable or disable component.


-- FILE NAME

---@class opts_filename
---@field enabled boolean Enable or disable component.


-- OPTIONS

---@class opts
---@field buffer opts_buffer Buffer number component
---@field diagnostics opts_diagnostics Diagnostics component
---@field quickfix_list opts_quickfixlist Quickfix list component
---@field git_status opts_gitstatus Git status component
---@field filepath opts_filepath Filepath component
---@field filesize opts_filesize Filesize component
---@field ruller opts_ruller Ruller component
---@field filename opts_filename Filename component
---@field separator string Separator between components


---@type opts
M.opt = {
	buffer = {
		enabled = true,
		prefix = "B:",
		symbol = "0",
		max_symbols = 5,
	},
	diagnostics = {
		enabled = true,
	},
	quickfix_list = {
		enabled = true,
	},
	git_status = {
		enabled = true,
	},
	filepath = {
		enabled = true,
		path = "relative",
		shorten = false,
	},
	filesize = {
		enabled = true,
		metric = "decimal"
	},
	ruller = {
		enabled = true,
	},
	filename = {
		enabled = true,
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
