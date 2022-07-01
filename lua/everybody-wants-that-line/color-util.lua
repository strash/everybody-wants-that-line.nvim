local U = require("everybody-wants-that-line.util")

local M = {}

---Returns default color
---@return table { hex: string, rgb: table, hsb: table }
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
---@return table { r: integer, g: integer, b: integer }
function M.hex_to_rgb(hex)
	local rgb = {}
	table.insert(rgb, tonumber(hex:sub(1, 2), 16))
	table.insert(rgb, tonumber(hex:sub(3, 4), 16))
	table.insert(rgb, tonumber(hex:sub(5, 6), 16))
	return rgb
end

---Convert rgb to hex
---@param r integer from 0 to 255
---@param g integer from 0 to 255
---@param b integer from 0 to 255
---@return string \'FFFFFF\'
function M.rgb_to_hex(r, g, b)
	return table.concat({
		string.format("%02x", r),
		string.format("%02x", g),
		string.format("%02x", b),
	})
end

---Convert rgb to hsb
---@param r integer from 0 to 255
---@param g integer from 0 to 255
---@param b integer from 0 to 255
---@return table { r: integer, g: integer, b: integer }
function M.rgb_to_hsb(r, g, b)
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

---Convert hsb to rgb
---@param h integer from 0 to 360
---@param s integer from 0 to 100
---@param v integer from 0 to 100
---@return table { r: integer, g: integer, b: integer }
function M.hsb_to_rgb(h, s, v)
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

---Blend colors
---@param intensity number from 0 to 1
---@param from table palette with rgb table at least - { hex: string, rgb: table, hsb: table }
---@param to table palette with rgb table at least - { hex: string, rgb: table, hsb: table }
---@return table { hex: string, rgb: table, hsb: table }
function M.blend_colors(intensity, from, to)
	local hex = ""
	local rgb = {}
	local hsb = {}
	if from.rgb ~= nil and to.rgb ~= nil then
		for i = 1, 3 do
			local rgb_c = math.floor(U.lerp(intensity, from.rgb[i], to.rgb[i]))
			table.insert(rgb, rgb_c)
		end
		hex = M.rgb_to_hex(rgb[1], rgb[2], rgb[3])
		hsb = M.rgb_to_hsb(rgb[1], rgb[2], rgb[3])
		return { hex = hex, rgb = rgb, hsb = hsb }
	end
	return M.get_default_color_palette()
end

--- Get hightlight group color
---@param group_name string name of the hightlight group, e.g. 'StatusLine'
---@param color string either 'foreground' or 'background'
---@return table { hex: string, rgb: table, hsb: table }
function M.get_hl_group_color(group_name, color)
	local hex = ""
	local rgb = {}
	local hsb = {}
	local hlid = vim.fn.hlID(group_name)
	if hlid ~= 0 then
		local group_table = vim.api.nvim_get_hl_by_id(hlid, true)
		if group_table[color] ~= nil then
			hex = M.vim_to_hex(group_table[color])
			rgb = M.hex_to_rgb(hex)
			hsb = M.rgb_to_hsb(rgb[1], rgb[2], rgb[3])
			return { hex = hex, rgb = rgb, hsb = hsb }
		end
	end
	return M.get_default_color_palette()
end

---Guessing color by its rgb component between 'foreground' and 'background' colors
---@param group_name string name of the hightlight group, e.g. 'StatusLine'
---@param rgb_component integer rgb color component index from rgb table, { r - 1, g - 2, b - 3 }
---@return table { hex: string, rgb: table, hsb: table }
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

---Adjust colors using another palette
---@param color_palette table { hex: string, rgb: table, hsb: table }
---@param by_color_palette table { hex: string, rgb: table, hsb: table }
---@return table { hex: string, rgb: table, hsb: table }
function M.adjust_color(color_palette, by_color_palette)
	local hsb, rgb, hex = color_palette.hsb, color_palette.rgb, color_palette.hex
	if hsb[2] < by_color_palette.hsb[2] then hsb[2] = by_color_palette.hsb[2] end
	if vim.o.background == "dark" then
		if hsb[3] < by_color_palette.hsb[3] then hsb[3] = by_color_palette.hsb[3] end
	else
		if hsb[3] > by_color_palette.hsb[3] then hsb[3] = by_color_palette.hsb[3] end
	end
	rgb = M.hsb_to_rgb(hsb[1], hsb[2], hsb[3])
	hex = M.rgb_to_hex(rgb[1], rgb[2], rgb[3])
	return { hex = hex, rgb = rgb, hsb = hsb }
end

---Returns formatted color group name
---@param color_group string
---@return string
function M.format_group_name(color_group)
	return "%#" .. color_group .. "#"
end

return M
