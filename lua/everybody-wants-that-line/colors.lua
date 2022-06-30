local U = require("everybody-wants-that-line.util")

local M = {}

-- colors
local colors = {}

-- color groups
M.color_group_names = {}

-- getting hightlight group color
local function get_hl_group_color(group_name, color)
	local hex = ""
	local rgb = {}
	local hlid = vim.fn.hlID(group_name)
	if hlid ~= 0 then
		local group_table = vim.api.nvim_get_hl_by_id(hlid, true)
		if group_table[color] ~= nil then
			hex = string.format("%06x", group_table[color]):upper()
			table.insert(rgb, tonumber(hex:sub(1, 2), 16))
			table.insert(rgb, tonumber(hex:sub(3, 4), 16))
			table.insert(rgb, tonumber(hex:sub(5, 6), 16))
			return { hex = hex, rgb = rgb }
		end
	end
	if vim.o.background == "dark" then
		return { hex = "FFFFFF", rgb = { 255, 255, 255 } }
	else
		return { hex = "000000", rgb = { 0, 0, 0 } }
	end
end

-- blend colors
local function blend_colors(intensity, from, to)
	local hex = ""
	local rgb = {}
	for i = 1, 3 do
		local l = math.floor(U.lerp(intensity, from[i], to[i]) or 255)
		hex = hex .. string.format("%02x", l)
		table.insert(rgb, l)
	end
	return { hex = hex, rgb = rgb }
end

-- return { h, s, b }
local function rgb_to_hsb(r, g, b)
	local _r, _g, _b = r / 255, g / 255, b / 255
	local max, min = math.max(_r, _g, _b), math.min(_r, _g, _b)
	local d, h, s, v
	v = max
	d = max - min
	s = max == 0 and 0 or d / max
	if max == min then h = 0
	else
		if     max == _r then h = (_g - _b) / d + (_g < _b and 6 or 0)
		elseif max == _g then h = (_b - _r) / d + 2
		elseif max == _b then h = (_r - _g) / d + 4
		end
	end
	return { U.round(h / 6 * 360), U.round(s * 100), U.round(v * 100) }
end

-- return { r, g, b }
local function hsb_to_rgb(h, s, v)
	local _h, _s, _v = h / 360, s / 100, v / 100
	local r, g, b, i, f, p, q, t, a
	i = math.floor(_h * 6)
	f = _h * 6 - i
	p = _v * (1 - _s)
	q = _v * (1 - f * _s)
	t = _v * (1 - (1 - f) * _s)
	a = i % 6
	if     a == 0 then r = _v g = t  b = p
	elseif a == 1 then r = q  g = _v b = p
	elseif a == 2 then r = p  g = _v b = t
	elseif a == 3 then r = p  g = q  b = _v
	elseif a == 4 then r = t  g = p  b = _v
	elseif a == 5 then r = _v g = p  b = q
	end
	return { U.round(r * 255), U.round(g * 255), U.round(b * 255) }
end

-- setting colors
local function set_colors()
	-- base colors
	colors = {
		bg = get_hl_group_color("StatusLine", "background"),
		fg = get_hl_group_color("StatusLine", "foreground"),
		bg_nc = get_hl_group_color("StatusLineNC", "background"),
		fg_nc = get_hl_group_color("StatusLineNC", "foreground"),
		fg_error = get_hl_group_color("DiagnosticError", "foreground"),
		fg_warn = get_hl_group_color("DiagnosticWarn", "foreground"),
		fg_info = get_hl_group_color("DiagnosticInfo", "foreground"),
		fg_add = get_hl_group_color("diffAdded", "foreground"),
		fg_remove = get_hl_group_color("diffRemoved", "foreground"),
	}
	-- blended colors
	for _, v in ipairs({ 20, 30, 50, 60 }) do
		colors["fg_" .. v] = blend_colors(v / 100, colors.bg.rgb, colors.fg.rgb)
		colors["fg_nc_" .. v] = blend_colors(v / 100, colors.bg_nc.rgb, colors.fg_nc.rgb)
	end
	colors.fg_error_50 = blend_colors(0.5, colors.bg.rgb, colors.fg_error.rgb)
	colors.fg_warn_50 = blend_colors(0.5, colors.bg.rgb, colors.fg_warn.rgb)
	colors.fg_info_50 = blend_colors(0.5, colors.bg.rgb, colors.fg_info.rgb)
	colors.fg_add_50 = blend_colors(0.5, colors.bg.rgb, colors.fg_add.rgb)
	colors.fg_remove_50 = blend_colors(0.5, colors.bg.rgb, colors.fg_remove.rgb)
end

-- setting color groups names
local function set_color_group_names()
	for k, _ in pairs(colors) do
		M.color_group_names[k] = U.prefix .. U.pascalcase(k)
		M.color_group_names[k .. "_bold"] = U.prefix .. U.pascalcase(k .. "_bold")
	end
end

-- setting hightlight group
local function set_hl_group(color_group, fg, cterm)
	vim.cmd("hi " .. color_group .. U.cterm(cterm) .. "guifg=#" .. fg .. " guibg=#" .. colors.bg.hex)
end

-- setting hightlight groups
local function set_hl_groups()
	for k, v in pairs(M.color_group_names) do
		local b = k:find("_bold")
		if b ~= nil then
			set_hl_group(v, colors[k:sub(1, b - 1)].hex, "bold")
		else
			set_hl_group(v, colors[k].hex, "")
		end
	end
end

-- formatted color group
function M.get_statusline_group(color_group)
	return "%#" .. color_group .. "#"
end

set_colors()
set_color_group_names()
set_hl_groups()

function M.setup_autocmd(group_name)
	vim.api.nvim_create_autocmd({
		"VimEnter",
		"ColorScheme",
	}, {
		pattern = "*",
		callback = function()
			set_colors()
			set_color_group_names()
			set_hl_groups()
		end,
		group = group_name,
	})
end

return M
