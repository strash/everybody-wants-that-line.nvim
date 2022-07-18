local U = require("everybody-wants-that-line.utils.util")

local M = {}
---@alias rgb integer[]
---@alias hsb integer[]
---@alias color_palette { hex: string, rgb: rgb, hsb: hsb }
---@alias color_ground '"background"'|'"foreground"'

---Returns default color palette
---@return color_palette `{ hex, rgb, hsb }`
function M.get_default_color_palette()
	if vim.o.background == "dark" then
		return { hex = "FFFFFF", rgb = { 255, 255, 255 }, hsb = { 0, 0, 100 } }
	else
		return { hex = "000000", rgb = { 0, 0, 0 }, hsb = { 0, 0, 0 } }
	end
end

---Convert vim 24bit color to hex
---@param vim_color integer 13291732
---@return string \'FFFFFF\'
function M.vim_to_hex(vim_color)
	return string.format("%06x", vim_color):upper()
end

---Convert hex to rgb
---@param hex string \'FFFFFF\'
---@return rgb `{ r, g, b }` each number from 0 to 255
function M.hex_to_rgb(hex)
	return {
		tonumber(hex:sub(1, 2), 16),
		tonumber(hex:sub(3, 4), 16),
		tonumber(hex:sub(5, 6), 16),
	}
end

---Convert rgb to hex
---@param rgb rgb each number from 0 to 255
---@return string \'FFFFFF\'
function M.rgb_to_hex(rgb)
	return table.concat({
		string.format("%02x", rgb[1]),
		string.format("%02x", rgb[2]),
		string.format("%02x", rgb[3]),
	})
end

---Convert rgb to hsb
---@param rgb rgb `{ r, g, b }` each number from 0 to 255
---@return hsb `{ h, s, b }` h 0-360, s 0-100, b 0-100
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

---Convert hsb to rgb
---@param hsb hsb `{ h, s, b }` h 0-360, s 0-100, b 0-100
---@return rgb `{ r, g, b }` each number from 0 to 255
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

---Blend colors
---@param intensity number from 0 to 1
---@param from color_palette palette with rgb table at least - { hex: string, rgb: integer[], hsb: integer[] }
---@param to color_palette palette with rgb table at least - { hex: string, rgb: integer[], hsb: integer[] }
---@return color_palette `{ hex, rgb, hsb }`
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

--- Get hightlight group color
---@param group_name string name of the hightlight group, e.g. `"StatusLine"`
---@param color color_ground `"foreground"|"background"`
---@return color_palette `{ hex, rgb, hsb }`
function M.get_hl_group_color(group_name, color)
	local hlid = vim.fn.hlID(group_name)
	if hlid ~= 0 then
		---@type table<color_ground>
		local group_table = vim.api.nvim_get_hl_by_id(hlid, true)
		if group_table[color] ~= nil then
			local hex = M.vim_to_hex(group_table[color])
			local rgb = M.hex_to_rgb(hex)
			local hsb = M.rgb_to_hsb(rgb)
			return { hex = hex, rgb = rgb, hsb = hsb }
		end
	end
	return M.get_default_color_palette()
end

---Guessing color by its rgb component between `"foreground"` and `"background"` colors
---@param group_name string name of the hightlight group, e.g. `"StatusLine"`
---@param rgb_component integer it is index from rgb table, e.g `1|2|3`
---@return color_palette `{ hex, rgb, hsb }`
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

---Returns adjusted copy of `color_palette`
---@param color_palette color_palette `{ hex, rgb, hsb }`
---@param by_color_palette color_palette `{ hex, rgb, hsb }`
---@return color_palette `{ hex, rgb, hsb }`
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
---@return string
function M.highlight_text(text, group_name)
	return "%#" .. M.get_group_name(group_name) .. "#" .. text .. "%*"
end

return M
