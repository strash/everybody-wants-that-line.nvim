local Math = {}

---Static. Returns linearly interpolated number
---@param value number from 0.0 to 1.0
---@param a number
---@param b number
---@return number
function Math.lerp(value, a, b)
	value = math.max(math.min(value, 1), 0)
	if a and b then
		return (1.0 - value) * a + b * value
	else
		return b
	end
end

---Static. Returns rounded integer from `v`
---@param value number
---@return integer
function Math.round(value)
	if tostring(value):find("%.") == nil then
		return math.floor(value)
	else
		local dec = tonumber(tostring(value):match("%.%d+"))
		if dec >= 0.5 then
			return math.ceil(value)
		else
			return math.floor(value)
		end
	end
end

---Static. Returns wrapped integer `v` between `min` and `max`
---@param value integer
---@param min integer
---@param max integer
---@return number
function Math.wrapi(value, min, max)
	local range = max - min
	return range == 0 and min or min + ((((value - min) % range) + range) % range)
end

---@alias file_size_suffix
---| "B"   # byte
---| "KB"  # kilobyte
---| "MB"  # megabyte
---| "KiB" # kibibyte
---| "MiB" # mebibyte

---@alias file_size { size: integer, suffix: file_size_suffix }

---Static. Returns decimal file size `{ size = 1000, suffix = "KB" }`
---@return file_size
function Math.decimal_file_size()
	local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
	size = size > 0 and size or 0
	-- bytes
	if size < 1000 then
		return { size = size, suffix = "B" }
	-- kilobytes
	elseif size >= 1000 and size <= 1000000 then
		return { size = Math.round(size * 10^-3 * 100) / 100, suffix = "KB" }
	end
	-- megabytes
	return { size = Math.round(size * 10^-6 * 100) / 100, suffix = "MB" }
end

---Static. Returns binary file size `{ size = 1024, suffix = "KiB" }`
---@return file_size
function Math.binary_file_size()
	local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
	size = size > 0 and size or 0
	-- bytes
	if size < 1024 then
		return { size = size, suffix = "B" }
	-- kibibytes
	elseif size >= 1024 and size <= 1048576 then
		return { size = Math.round(size * 2^-10 * 100) / 100, suffix = "KiB" }
	end
	-- mebibytes
	return { size = Math.round(size * 2^-20 * 100) / 100, suffix = "MiB" }
end

return Math

