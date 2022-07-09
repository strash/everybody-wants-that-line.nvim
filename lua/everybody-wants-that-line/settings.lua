local M = {}

---@alias filepath
---| "tail" # File name only
---| "relative" # Relative to working directory
---| "full" # Full path to the file

M.opt = {
	buffer = {
		prefix = "b",
		symbol = "0",
		max_symbols = 5,
	},
	filepath = {
		---@type filepath
		path = "relative",
		shorten = false,
	},
	separator = "│",
}

---Check if path matches a filename
---@param path filepath
---@return filepath
local function check_filepath(path)
	if path == "tail" or path == "relative" or path == "full" then
		return path
	end
	return "relative"
end

---Setup
---@param opt table
function M.setup(opt)
	if opt ~= nil and type(opt) == "table" then
		for k, v in pairs(opt) do
			if type(v) == "table" then
				for vk, vv in pairs(v) do
					if M.opt[k][vk] ~= nil and type(M.opt[k][vk]) == type(vv) then
						if k == "filepath" and vk == "path" then
							M.opt[k][vk] = check_filepath(vv)
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
