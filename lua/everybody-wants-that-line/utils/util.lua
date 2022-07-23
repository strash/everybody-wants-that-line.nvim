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

---@alias si_fsize_postfix
---| "B"  # byte
---| "KB" # kilobyte
---| "MB" # megabyte

---@alias si_fsize { size: integer, postfix: si_fsize_postfix }

---Returns decimal file size `{ size = 1000, postfix = "KB" }`
---@return si_fsize
function M.si_fsize()
	local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
	size = size > 0 and size or 0
	-- bytes
	if size < 1000 then
		return { size = size, postfix = "B" }
	-- kilobytes
	elseif size >= 1000 and size <= 1000000 then
		return { size = M.round(size * 10^-3 * 100) / 100, postfix = "KB" }
	end
	-- megabytes
	return { size = M.round(size * 10^-6 * 100) / 100, postfix = "MB" }
end

---@alias bi_fsize_postfix
---| "B"   # byte
---| "KiB" # kibibyte
---| "MiB" # mebibyte

---@alias bi_fsize { size: integer, postfix: bi_fsize_postfix }

---Returns binary file size `{ size = 1024, postfix = "KiB" }`
---@return bi_fsize
function M.bi_fsize()
	local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
	size = size > 0 and size or 0
	-- bytes
	if size < 1024 then
		return { size = size, postfix = "B" }
	-- kibibytes
	elseif size >= 1024 and size <= 1048576 then
		return { size = M.round(size * 2^-10 * 100) / 100, postfix = "KiB" }
	end
	-- mebibytes
	return { size = M.round(size * 2^-20 * 100) / 100, postfix = "MiB" }
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

---Returns current buffer number
---@return number
function M.get_bufnr()
	local bufnr
	if M.laststatus() == 3 then
		bufnr = vim.api.nvim_get_current_buf()
	else
		bufnr = M.is_focused() and tonumber(vim.g.actual_curbuf) or vim.api.nvim_get_current_buf()
	end
	return bufnr
end

---@alias laststatus
---| 0 #never
---| 1 #only if there are at least two windows
---| 2 #always
---| 3 #always and ONLY the last window

---Returns `laststatus`
---@return laststatus
function M.laststatus()
	return vim.o.laststatus
end

---@alias vim_wintype
---| ""         # normal window (or NvimTree)
---| "autocmd"  # autocommand window. Temporary window used to execute autocommands
---| "command"  # command-line window `cmdwin`
---| "loclist"  # `location-list-window`
---| "popup"    # popup window `popup`
---| "preview"  # preview window `preview-window`
---| "quickfix" # `quickfix-window`
---| "unknown"  # window `{nr}` not found

---@alias vim_buftype
---| ""         # normal buffer
---| "acwrite"  # buffer will always be written with `BufWriteCmd`s
---| "help"     # help buffer (do not set this manually)
---| "nofile"   # buffer is not related to a file, will not be written (NvimTree)
---| "nowrite"  # buffer will not be written
---| "prompt"   # buffer where only the last line can be edited, meant to be used by a plugin, see `prompt-buffer`
---| "quickfix" # list of errors `:cwindow` or locations `:lwindow`
---| "terminal" # `terminal-emulator` buffer

---@alias wintype
---| "unknown"
---| "normal"
---| "loclist"
---| "quickfix"
---| "preview"
---| "help"
---| "nvimtree"
---| "packer"
---| "neogit"
---| "fugitive"
---| "telescope"

---Returns window type
---@return wintype enum
function M.get_wintype()
	local buff_name = vim.api.nvim_buf_get_name(0)
	---@type vim_wintype
	local wintype = vim.fn.win_gettype()
	---@type vim_buftype
	local buftype = vim.o.buftype
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
