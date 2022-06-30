local U = require("everybody-wants-that-line.util")

local M = {}

function M.get_default_color()
	if vim.o.background == "dark" then
		return { hex = "FFFFFF", rgb = { 255, 255, 255 } }
	else
		return { hex = "000000", rgb = { 0, 0, 0 } }
	end
end

-- getting hightlight group color
function M.get_hl_group_color(group_name, color)
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
	return M.get_default_color()
end

-- blend colors
function M.blend_colors(intensity, from, to)
	local hex = ""
	local rgb = {}
	if from.rgb ~= nil and to.rgb ~= nil then
		for i = 1, 3 do
			local l = math.floor(U.lerp(intensity, from.rgb[i], to.rgb[i]))
			hex = hex .. string.format("%02x", l)
			table.insert(rgb, l)
		end
		return { hex = hex, rgb = rgb }
	end
	return M.get_default_color()
end

-- return { h, s, b }
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

-- return { r, g, b }
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

return M
