local U = require("everybody-wants-that-line.utils.util")

local M = {}
---@alias rgb integer[] each number from 0 to 255
---@alias hsb integer[] h 0-360, s 0-100, b 0-100
---@alias color_palette { hex: string, rgb: rgb, hsb: hsb }
---@alias color_ground '"background"'|'"foreground"'

---Returns default color palette. Black color for "light" background
---or white color for "dark" background, e.g. `{ hex, rgb, hsb }`
---@return color_palette
function M.get_default_color_palette()
	if vim.o.background == "dark" then
		return { hex = "FFFFFF", rgb = { 255, 255, 255 }, hsb = { 0, 0, 100 } }
	else
		return { hex = "000000", rgb = { 0, 0, 0 }, hsb = { 0, 0, 0 } }
	end
end

---Convert 24bit rgb color to hex, e.g. `16777215` -> `FFFFFF`
---@param vim_color integer
---@return string
function M.vim_to_hex(vim_color)
	return string.format("%06x", vim_color):upper()
end

---Convert hex to 8bit rgb color, e.g. `FFFFFF` -> `{ 255, 255, 255 }`
---@param hex string
---@return rgb
function M.hex_to_rgb(hex)
	return {
		tonumber(hex:sub(1, 2), 16),
		tonumber(hex:sub(3, 4), 16),
		tonumber(hex:sub(5, 6), 16),
	}
end

---Convert 24bit rgb color to 8bit rgb, e.g. `16777215` -> `{ 255, 255, 255 }`
---@param vim_color integer
---@return rgb
function M.vim_to_rgb(vim_color)
	---@type rgb
	local rgb = {
		bit.band(bit.rshift(vim_color, 16), 255),
		bit.band(bit.rshift(vim_color, 8), 255),
		bit.band(vim_color, 255),
	}
	return rgb
end

---Convert 8bit rgb to hex color, e.g. `{ 255, 255, 255 }` -> `FFFFFF`
---@param rgb rgb
---@return string
function M.rgb_to_hex(rgb)
	return table.concat({
		string.format("%02x", rgb[1]),
		string.format("%02x", rgb[2]),
		string.format("%02x", rgb[3]),
	}):upper()
end

---Convert 8bit rgb to hsb color, e.g. `{ 255, 255, 255 }` -> `{ 0, 0, 100 }`
---@param rgb rgb
---@return hsb
function M.rgb_to_hsb(rgb)
	local _r, _g, _b = rgb[1] / 255, rgb[2] / 255, rgb[3] / 255
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
	return {
		U.round(h / 6 * 360),
		U.round(s * 100),
		U.round(v * 100)
	}
end

---Convert hsb to 8bit rgb color, e.g. `{ 0, 0, 100 }` -> `{ 255, 255, 255 }`
---@param hsb hsb
---@return rgb
function M.hsb_to_rgb(hsb)
	local _h, _s, _b = hsb[1] / 360, hsb[2] / 100, hsb[3] / 100
	local r, g, b, i, f, p, q, t, a
	i = math.floor(_h * 6)
	f = _h * 6 - i
	p = _b * (1 - _s)
	q = _b * (1 - f * _s)
	t = _b * (1 - (1 - f) * _s)
	a = i % 6
	if     a == 0 then r = _b g = t  b = p
	elseif a == 1 then r = q  g = _b b = p
	elseif a == 2 then r = p  g = _b b = t
	elseif a == 3 then r = p  g = q  b = _b
	elseif a == 4 then r = t  g = p  b = _b
	elseif a == 5 then r = _b g = p  b = q
	end
	return {
		U.round(r * 255),
		U.round(g * 255),
		U.round(b * 255)
	}
end

---Blend colors between two color palettes
---@param intensity number from 0.0 to 1.0
---@param from color_palette
---@param to color_palette
---@return color_palette
function M.blend_colors(intensity, from, to)
	if from.rgb ~= nil and to.rgb ~= nil then
		local rgb = {}
		for i = 1, 3 do
			local rgb_c = math.floor(U.lerp(intensity, from.rgb[i], to.rgb[i]))
			table.insert(rgb, rgb_c)
		end
		local hex = M.rgb_to_hex(rgb)
		local hsb = M.rgb_to_hsb(rgb)
		return { hex = hex, rgb = rgb, hsb = hsb }
	end
	return M.get_default_color_palette()
end

---Returns reversed color ground `"foreground" -> "background"`
---@param color color_ground
---@return color_ground
function M.reverse_color_ground(color)
	if color == "background" then
		return "foreground"
	else
		return "background"
	end
end

--- Get hightlight group color palette
---@param group_name string name of the hightlight group, e.g. `"StatusLine"`
---@param color color_ground
---@return color_palette
function M.get_hl_group_color(group_name, color)
	local hlid = vim.fn.hlID(group_name)
	if hlid ~= 0 then
		---@type { background: string|nil, foreground: string|nil, reverse: boolean|nil, bold: boolean|nil }
		local group_table = vim.api.nvim_get_hl_by_id(hlid, true)
		local c = color
		if group_table["reverse"] ~= nil and group_table["reverse"] == true then
			c = M.reverse_color_ground(c)
		end
		if group_table[c] ~= nil then
			local hex = M.vim_to_hex(group_table[c])
			local rgb = bit ~= nil and M.vim_to_rgb(group_table[c]) or M.hex_to_rgb(hex)
			local hsb = M.rgb_to_hsb(rgb)
			return { hex = hex, rgb = rgb, hsb = hsb }
		end
	end
	return M.get_default_color_palette()
end

---Guessing color by its rgb component between `"foreground"` and `"background"` colors
---@param group_name string name of the hightlight group, e.g. `"StatusLine"`
---@param rgb_component 1|2|3
---@return color_palette
function M.choose_right_color(group_name, rgb_component)
	local c = rgb_component
	local color = {
		fg = M.get_hl_group_color(group_name, "foreground"),
		bg = M.get_hl_group_color(group_name, "background"),
	}
	local is_fg_right_color = color.fg.rgb[c] > color.fg.rgb[U.wrapi(c - 1, 1, 3)] and color.fg.rgb[c] > color.fg.rgb[U.wrapi(c + 1, 1, 3)]
	local is_bg_right_color = color.bg.rgb[c] > color.bg.rgb[U.wrapi(c - 1, 1, 3)] and color.bg.rgb[c] > color.bg.rgb[U.wrapi(c + 1, 1, 3)]
	if is_fg_right_color and not is_bg_right_color then
		return color.fg
	elseif not is_fg_right_color and is_bg_right_color then
		return color.bg
	else
		return color.fg
	end
end

---Returns adjusted copy of color palette
---@param color_palette color_palette
---@param by_color_palette color_palette
---@return color_palette
function M.adjust_color(color_palette, by_color_palette)
	local hex, rgb
	local hsb = color_palette.hsb
	if hsb[2] < by_color_palette.hsb[2] then hsb[2] = by_color_palette.hsb[2] end
	if vim.o.background == "dark" then
		if hsb[3] < by_color_palette.hsb[3] then hsb[3] = by_color_palette.hsb[3] end
	else
		if hsb[3] > by_color_palette.hsb[3] then hsb[3] = by_color_palette.hsb[3] end
	end
	rgb = M.hsb_to_rgb(hsb)
	hex = M.rgb_to_hex(rgb)
	return { hex = hex, rgb = rgb, hsb = hsb }
end

---Returns right group name. `...Nc` (not current) or current (in active StatusLine)
---@param group_name string
---@return string
function M.get_group_name(group_name)
	if U.laststatus() == 3 then
		return group_name
	end
	return U.is_focused() and group_name or U.prefix .. group_name:sub(#U.prefix + 1, #U.prefix + 2) .. "Nc" .. group_name:sub(#U.prefix + 3)
end

---Returns highlighted text
---@param text string
---@param group_name string
---@param is_nc nil|boolean If `true` then `group_name` must be a `[nc]`. Default is `false`
---@return string
function M.highlight_text(text, group_name, is_nc)
	if is_nc == nil then
		is_nc = false
	end
	return "%#" .. (is_nc and group_name or M.get_group_name(group_name)) .. "#" .. text .. "%*"
end

return M
