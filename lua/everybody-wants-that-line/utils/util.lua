local M = {}

M.prefix = "EverybodyWantsThatLine"

---Returns joined string with delimiter.
---@generic T : string | string[]
---@param components T[] Table of strings and/or tables with strings
---@param with string Delimiter
---@return string
function M.join(components, with)
	if type(components) ~= "table" and type(components) ~= "string" then
		return ""
	end
	local result = ""
	for i, v in ipairs(components) do
		if type(v) ~= "string" and type(v) ~= "table" then
			v = tostring(v)
		end
		if #v ~= 0 then
			if i == 1 or #result == 0 then
				result = type(v) == "table" and table.concat(v) or v
			else
				result = result .. with .. (type(v) == "table" and table.concat(v) or v)
			end
		end
	end
	return result
end

---Returns linearly interpolated number
---@param v number from 0.0 to 1.0
---@param a number
---@param b number
---@return number
function M.lerp(v, a, b)
	v = math.max(math.min(v, 1), 0)
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
	if M.laststatus() == 3 then
		return true
	end
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

---Check if window valid
---@param win_id number
---@return boolean
function M.is_win_valid(win_id)
	return win_id ~= nil and vim.api.nvim_win_is_valid(win_id)
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

---@alias cache_item_variant { n: string, nc: string }

---Returns either `n` or `nc` cache item variant
---@param cache_item cache_item_variant
---@return string
function M.get_cache_item_variant(cache_item)
	if M.is_focused() then
		return cache_item.n
	else
		return cache_item.nc
	end
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
---| "netrw"
---| "lazy"           # folke/lazy.nvim
---| "packer"         # wbthomason/packer.nvim
---| "neogit"         # TimUntersberger/neogit
---| "fugitive"       # tpope/vim-fugitive
---| "telescope"      # nvim-telescope/telescope.nvim
---| "buffer_manager" # j-morano/buffer_manager.nvim
---| "nvimtree"       # nvim-tree/nvim-tree.lua
---| "neo-tree"       # nvim-neo-tree/neo-tree.nvim
---| "dirbuf"         # elihunter173/dirbuf.nvim

---Returns window type
---@param win_id number|nil
---@return wintype enum
function M.get_wintype(win_id)
	win_id = win_id or vim.fn.win_getid()
	---@type vim_wintype
	local vim_wintype = vim.fn.win_gettype(win_id)
	---@type vim_buftype
	local buftype = vim.o.buftype
	---@type string
	local filetype = vim.o.filetype

	---@type wintype
	local wintype = "unknown"

	if vim_wintype == "" or vim_wintype == "popup" then
		if buftype == "" then
			if filetype == "netrw" then
				wintype = "netrw"
			else
				wintype = "normal"
			end
		elseif buftype == "nofile" then
			if filetype == "NvimTree" then
				wintype = "nvimtree"
			elseif filetype == "neo-tree" then
				wintype = "neo-tree"
			elseif filetype == "packer" then
				wintype = "packer"
			elseif filetype:find("Neogit") ~= nil then
				wintype = "neogit"
			elseif filetype == "lazy" then
				wintype = "lazy"
			else
				wintype = "unknown"
			end
		elseif buftype == "prompt" then
			if filetype:find("Telescope") ~= nil then
				wintype = "telescope"
			end
		elseif buftype == "nowrite" then
			if filetype == "fugitive" then
				wintype = "fugitive"
			end
		elseif buftype == "help" then
			wintype = "help"
		elseif buftype == "acwrite" then
			if filetype == "dirbuf" then
				wintype = "dirbuf"
			elseif filetype == "buffer_manager" then
				wintype = "buffer_manager"
			end
		end
	elseif vim_wintype == "loclist" then
		wintype = "loclist"
	elseif vim_wintype == "quickfix" then
		wintype = "quickfix"
	elseif vim_wintype == "preview" then
		wintype = "preview"
	end

	-- for debug
	--vim.api.nvim_notify(
	--	"vim wintype '" .. vim_wintype ..
	--	"', buftype '" .. buftype ..
	--	"', filetype '" .. filetype ..
	--	"', wintype '" .. wintype .. "'",
	--	vim.log.levels.INFO,
	--{})
	return wintype
end

return M
