local M = {}

M.prefix = "EverybodyWantsThatLine"

---Returns linearly interpolated number
---@param v number from 0.0 to 1.0
---@param a number
---@param b number
---@return number
function M.lerp(v, a, b)
	if a and b then
		return (1.0 - v) * a + b * v
	else
		return b
	end
end

---Returns rounded integer from `v`
---@param v number
---@return integer
function M.round(v)
	if tostring(v):find("%.") == nil then
		return math.floor(v)
	else
		local dec = tonumber(tostring(v):match("%.%d+"))
		if dec >= 0.5 then
			return math.ceil(v)
		else
			return math.floor(v)
		end
	end
end

---Returns wrapped integer `v` between `min` and `max`
---@param v integer
---@param min integer
---@param max integer
---@return number
function M.wrapi(v, min, max)
	local range = max - min
	return range == 0 and min or min + ((((v - min) % range) + range) % range)
end

---Returns file size
---@return table `{ 12.34, "B"/"KB"/"MB" }`
function M.si_fsize()
	local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
	-- bytes
	if size <= 1000 then
		return { size, "B" }
	-- kilobytes
	elseif size > 1000 and size <= 1000000 then
		return { M.round(size * 10^-3 * 100) / 100, "KB" }
	end
	-- megabytes
	return { M.round(size * 10^-6 * 100) / 100, "MB" }
end

---Returns file size
---@return table `{ 12.34, "B"/"KiB"/"MiB" }`
function M.binary_fsize()
	local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
	-- bytes
	if size <= 1024 then
		return { size, "B" }
	-- kilobytes
	elseif size > 1024 and size <= 1048576 then
		return { M.round(size * 2^-10 * 100) / 100, "KiB" }
	end
	-- megabytes
	return { M.round(size * 2^-20 * 100) / 100, "MiB" }
end

---Check if a value exist in an enumerated table
---@param t table
---@param v any
---@return boolean
function M.is_value_exist(t, v)
	local is_value_exist = false
	for _, _v in ipairs(t) do
		if _v == v then
			is_value_exist = true
			break
		end
	end
	return is_value_exist
end

---@alias cterm ""|"bold"

---Returns cterm for a highlight group
---@param v cterm e.g. 'bold'
---@return string
function M.cterm(v)
	local c = " "
	if #v > 0 then
		c = " cterm=" .. v .. " gui=" .. v .. " "
	end
	return c
end

---Returns string in PascalCase
---@param s string
---@return string
function M.pascalcase(s)
	local parts = {}
	for i in string.gmatch(s, "%w+") do
		table.insert(parts, i:sub(0, 1):upper() .. i:sub(2))
	end
	return table.concat(parts)
end

---Check if statusline on focused window
---@return boolean
function M.is_focused()
	return tonumber(vim.g.actual_curwin) == vim.api.nvim_get_current_win()
end

---Returns `laststatus`
---@return number
function M.laststatus()
	return vim.o.laststatus
end

---@alias wintype
---| "unknown"
---| "normal",
---| "loclist",
---| "quickfix",
---| "preview",
---| "help",
---| "nvimtree",
---| "packer",
---| "neogit",
---| "fugitive",
---| "telescope",

---Returns window type
---@return wintype enum
function M.get_wintype()
	local buff_name = vim.api.nvim_buf_get_name(0)
	local wintype = vim.fn.win_gettype() -- empty (normal or NvimTree), loclist, popup, preview, quickfix, unknown
	local buftype = vim.o.buftype -- help, quickfix, terminal, prompt, nofile (NvimTree)
	if wintype == "" then
		if wintype == "" and buftype == "nofile" then
			if buff_name:find("NvimTree_1$") ~= nil then
				return "nvimtree"
			elseif buff_name:find("%[packer%]") ~= nil then
				return "packer"
			elseif buff_name:find("Neogit") then
				return "neogit"
			else
				return "unknown"
			end
		elseif buftype == "nowrite" and buff_name:find(".git/index$") ~= nil then
			return "fugitive"
		elseif buftype == "help" then
			return "help"
		elseif buftype ~= "nofile" and buff_name:find("NvimTree_1$") == nil then
			return "normal"
		end
	elseif wintype == "popup" and buftype == "prompt" then
		return "telescope"
	elseif wintype == "loclist" then
		return "loclist"
	elseif wintype == "quickfix" then
		return "quickfix"
	elseif wintype == "preview" then
		return "preview"
	end
	return "unknown"
end

return M
