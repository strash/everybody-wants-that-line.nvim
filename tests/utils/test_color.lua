local UC = require("everybody-wants-that-line.utils.color")
local UU = require("everybody-wants-that-line.utils.util")

local eq = MiniTest.expect.equality
local T = MiniTest.new_set()
local child = MiniTest.new_child_neovim()

local hex = {
	white = "FFFFFF",
	black = "000000",
}
local rgb = {
	white = {255,255,255},
	black = {0,0,0},
}
local hsb = {
	white = {0,0,100},
	black = {0,0,0},
}

T["vim_to_hex"] = function()
	eq(UC.vim_to_hex(16777215), hex.white)
end

T["hex_to_rgb"] = function()
	eq(UC.hex_to_rgb(hex.white), rgb.white)
end

T["vim_to_rgb"] = function()
	eq(UC.vim_to_rgb(16777215), rgb.white)
end

T["rgb_to_hex"] = function()
	eq(UC.rgb_to_hex(rgb.white), hex.white)
end

T["rgb_to_hsb"] = function()
	eq(UC.rgb_to_hsb(rgb.white), hsb.white)
end

T["hsb_to_rgb"] = function()
	eq(UC.hsb_to_rgb(hsb.white), rgb.white)
end

T["blend_colors"] = function()
	eq(UC.blend_colors(0.5,
		{hex=hex.white, rgb=rgb.white, hsb=hsb.white},
		{hex=hex.black, rgb=rgb.black, hsb=hsb.black}),
		{hex="7F7F7F", rgb={127,127,127}, hsb={0,0,50}}
)
end

T["reverse_color_ground"] = function()
	eq(UC.reverse_color_ground("background"), "foreground")
end

T["color"] = MiniTest.new_set({
	hooks = {
		pre_case = function()
			child.restart({ "-u", "tests/minimal_init.lua" })
			child.lua([[M = require("everybody-wants-that-line.utils.color")]])
			child.cmd([[colo blue | lua vim.o.background = "dark"]])
		end,
		post_once = function()
			child.stop()
		end,
	},
}, {
	get_hl_group_color = function()
		local palette = {hex="00FFFF", rgb={0,255,255}, hsb={180,100,100}}
		eq(child.lua([[return M.get_hl_group_color("StatusLine", "foreground")]]), palette)
	end,
	choose_right_color = function()
		local palette = {hex="000000", rgb={0,0,0}, hsb={0,0,0}}
		eq(child.lua([[return M.choose_right_color("DiffAdd", 2)]]), palette)
	end,
	adjust_color = function()
		child.lua([[_G.palette_in = {hex="622323", rgb={98,35,35}, hsb={0,64,38}}]])
		child.lua([[_G.palette_by = {hex="DFFFB6", rgb={223,255,182}, hsb={86,29,100}}]])
		local palette_out = {hex="FF5C5C", rgb={255,92,92}, hsb={0,64,100}}
		eq(child.lua([[return M.adjust_color(_G.palette_in,_G.palette_by)]]), palette_out)
	end,
})

T["misc"] = MiniTest.new_set({
	hooks = {
		pre_case = function()
			child.restart({ "-u", "tests/minimal_init.lua" })
			child.lua([[require("everybody-wants-that-line").setup()]])
			child.lua([[M = require("everybody-wants-that-line.utils.color")]])
			child.cmd([[colo blue | set laststatus=2]])
		end,
		post_once = function()
			child.stop()
		end,
	},
}, {
	get_group_name = function()
		eq(child.lua([[return M.get_group_name(require("everybody-wants-that-line.colors").group_names.fg_60)]]),
			UU.prefix .. "FgNc60") -- `Nc` for some reason
	end,
	highlight_text = function()
		local text = "some random ass text"
		eq(child.lua([[return M.highlight_text("some random ass text", require("everybody-wants-that-line.colors").group_names.fg_60)]]),
			"%#" .. UU.prefix .. "FgNc60#" .. text .. "%*")
	end,
})

return T
