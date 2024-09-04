local Math = require("everybody-wants-that-line.utils.math")

---Convert 24bit rgb color to hex, e.g. `16777215` -> `FFFFFF`
---@param vim_color integer
---@return string
local function vim_to_hex(vim_color)
	return string.format("%06x", vim_color):upper()
end

---Convert hex to 8bit rgb color, e.g. `FFFFFF` -> `{ 255, 255, 255 }`
---@param hex string
---@return rgb
local function hex_to_rgb(hex)
	return {
		tonumber(hex:sub(1, 2), 16),
		tonumber(hex:sub(3, 4), 16),
		tonumber(hex:sub(5, 6), 16),
	}
end

---Convert 24bit rgb color to 8bit rgb, e.g. `16777215` -> `{ 255, 255, 255 }`
---@param vim_color integer
---@return rgb
local function vim_to_rgb(vim_color)
	---@type rgb
	local rgb = {
		bit.band(bit.rshift(vim_color, 16), 255),
		bit.band(bit.rshift(vim_color, 8), 255),
		bit.band(vim_color, 255),
	}
	return rgb
end

---Convert 8bit rgb color to 24bit, e.g. `{ 255, 255, 255 }` -> `16777215`
---@param rgb rgb
---@return integer
local function rgb_to_vim(rgb)
	return bit.lshift(rgb[1], 16) + bit.lshift(rgb[2], 8) + rgb[3]
end

---Convert 8bit rgb to hex color, e.g. `{ 255, 255, 255 }` -> `FFFFFF`
---@param rgb rgb
---@return string
local function rgb_to_hex(rgb)
	return table.concat({
		string.format("%02x", rgb[1]),
		string.format("%02x", rgb[2]),
		string.format("%02x", rgb[3]),
	}):upper()
end

---Convert 8bit rgb to hsv color, e.g. `{ 255, 255, 255 }` -> `{ 0, 0, 100 }`
---@param rgb rgb
---@return hsv
local function rgb_to_hsv(rgb)
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
		Math.round(h / 6 * 360),
		Math.round(s * 100),
		Math.round(v * 100)
	}
end

---Convert hsv to 8bit rgb color, e.g. `{ 0, 0, 100 }` -> `{ 255, 255, 255 }`
---@param hsv hsv
---@return rgb
local function hsv_to_rgb(hsv)
	local _h, _s, _v = hsv[1] / 360, hsv[2] / 100, hsv[3] / 100
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
	return {
		Math.round(r * 255),
		Math.round(g * 255),
		Math.round(b * 255)
	}
end

---@alias rgb integer[] each number from 0 to 255
---@alias hsv integer[] h 0-360, s 0-100, b 0-100

---@class ColorData
---@field hex string 8bit rgb color, e.g. `"FFFFFF"`
---@field rgb rgb each number from 0 to 255
---@field hsv hsv h 0-360, s 0-100, b 0-100
---@field new fun(self: ColorData, vim_color: integer | nil): ColorData Creates new color data
---@field blend fun(self: ColorData, intensity: number, with: ColorData): ColorData Blend color to itself with intensity
---@field adjust_color fun(self: ColorData, by_color_data: ColorData): ColorData Returns adjusted copy of color

---@type ColorData
local ColorData = {
	hex = "FFFFFF",
	rgb = { 255, 255, 255 },
	hsv = { 0, 0, 100 },
}

---Static. Guessing color by its rgb component between `"foreground"` and `"background"` colors
---@param bg_color_data ColorData
---@param fg_color_data ColorData
---@param rgb_component 1|2|3
---@return ColorData
function ColorData.choose_right_color(bg_color_data, fg_color_data, rgb_component)
	local lhs = Math.wrapi(rgb_component - 1, 1, 3)
	local rhs = Math.wrapi(rgb_component + 1, 1, 3)
	local is_bg_right_color = (bg_color_data.rgb[rgb_component] > bg_color_data.rgb[lhs]) and (bg_color_data.rgb[rgb_component] > bg_color_data.rgb[rhs])
	local is_fg_right_color = (fg_color_data.rgb[rgb_component] > fg_color_data.rgb[lhs]) and (fg_color_data.rgb[rgb_component] > fg_color_data.rgb[rhs])
	if not is_fg_right_color and is_bg_right_color then
		return bg_color_data
	else
		return fg_color_data
	end
end

---Create new color data
---@param vim_color integer | nil
---@return ColorData
function ColorData:new(vim_color)
	local t = {}
	setmetatable(t, self)
	self.__index = self
	if vim_color then
		t.hex = vim_to_hex(vim_color)
		t.rgb = bit ~= nil and vim_to_rgb(vim_color) or hex_to_rgb(t.hex)
		t.hsv = rgb_to_hsv(t.rgb)
	end
	return t
end

---Blend color to itself with intensity
---@param intensity number How mutch color add to itself. A number from 0.0 to 1.0
---@param with ColorData
---@return ColorData
function ColorData:blend(intensity, with)
	local rgb = { self.rgb[1], self.rgb[2], self.rgb[3] }
	for i = 1, 3 do
		rgb[i] = math.floor(Math.lerp(intensity, rgb[i], with.rgb[i]))
	end
	return ColorData:new(rgb_to_vim(rgb))
end

---Returns adjusted copy of color
---@param by_color_data ColorData
---@return ColorData
function ColorData:adjust_color(by_color_data)
	---@type hsv
	local hsv = self.hsv
	if hsv[2] < by_color_data.hsv[2] then
		hsv[2] = by_color_data.hsv[2]
	end
	if vim.o.background == "dark" then
		if hsv[3] < by_color_data.hsv[3] then
			hsv[3] = by_color_data.hsv[3]
		end
	else
		if hsv[3] > by_color_data.hsv[3] then
			hsv[3] = by_color_data.hsv[3]
		end
	end
	local new_color = ColorData:new()
	new_color.hsv = hsv
	new_color.rgb = hsv_to_rgb(hsv)
	new_color.hex = rgb_to_hex(new_color.rgb)
	return new_color
end

return ColorData

