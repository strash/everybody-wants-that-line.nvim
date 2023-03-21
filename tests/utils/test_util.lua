local UU = require("everybody-wants-that-line.utils.util")

local eq, noteq = MiniTest.expect.equality, MiniTest.expect.no_equality
local child = MiniTest.new_child_neovim()

local T = MiniTest.new_set()

T["lerp"] = MiniTest.new_set({
	parametrize = { {0.5, 0, 50, 25}, {2.0, 0, 50, 50}, {-5.2, 0, 50, 0} },
}, {
	equal = function(v, a, b, c) eq(UU.lerp(v, a, b), c) end,
	not_equal = function() noteq(UU.lerp(1, -1, 0), 1) end,
})

T["round"] = MiniTest.new_set({
	parametrize = { {10.1, 10}, {10.5, 11} },
}, {
	equal = function(v, x) eq(UU.round(v), x) end
})

T["wrapi"] = MiniTest.new_set({
	parametrize = { {5,0,2,1}, {125,-11,22,-7}, {5,-15,-5,-15}, {-11,-15,-5,-11} },
}, {
	equal = function(v, min, max, x) eq(UU.wrapi(v, min, max), x) end,
	wrap_table_index = function()
		local t = { "one", "two", "three" }
		local text = t[UU.wrapi(10, 0, #t)]
		eq(text, "one")
	end
})

T["cterm"] = MiniTest.new_set({
	parametrize = { {"", " "}, {"bold", " cterm=bold gui=bold "} },
}, {
	equal = function(v, x) eq(UU.cterm(v), x) end
})

T["pascalcase"] = MiniTest.new_set({
	parametrize = { {"fg_nc_diff_delete_50", "FgNcDiffDelete50"}, {"fg___      _______50", "Fg50"} },
}, {
	equal = function(v, x) eq(UU.pascalcase(v), x) end
})

-- FILE SIZE
T["fsize"] = MiniTest.new_set({
	data = {
		fsize_text = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}
	},
	hooks = {
		pre_once = function()
			child.start({ "-u", "tests/minimal_init.lua" })
			child.fn.system("touch tests/utils/test_file")
		end,
		pre_case = function()
			child.restart({ "-u", "tests/minimal_init.lua" })
			child.lua([[M = require("everybody-wants-that-line.utils.util")]])
			child.lua([[_G.fsize = { size = 0, suffix = "B" }]])
			child.cmd("e tests/utils/test_file")
		end,
		post_case = function()
			child.cmd("%d | w")
		end,
		post_once = function()
			child.fn.system("rm tests/utils/test_file")
			child.stop()
		end,
	}
}, {
	si_bytes = function()
		eq(child.lua("return M.si_fsize()"), child.lua_get("_G.fsize"))
	end,

	si_kilobytes = function()
		local text = vim.deepcopy(MiniTest.current.case.data.fsize_text)
		for _ = 1, 9 do
			table.insert(text, text[1])
		end
		child.api.nvim_buf_set_text(0, 0, 0, 0, 0, text)
		child.cmd("w")
		child.lua([[_G.fsize.size = 1; _G.fsize.suffix = "KB"]])
		eq(child.lua("return M.si_fsize()"), child.lua_get("_G.fsize"))
	end,

	si_megabytes = function()
		local text = vim.deepcopy(MiniTest.current.case.data.fsize_text)
		for _ = 1, 10000 do
			table.insert(text, text[1])
		end
		child.api.nvim_buf_set_text(0, 0, 0, 0, 0, text)
		child.cmd("w")
		child.lua([[_G.fsize.size = 1; _G.fsize.suffix = "MB"]])
		eq(child.lua("return M.si_fsize()"), child.lua_get("_G.fsize"))
	end,

	bi_bytes = function()
		eq(child.lua("return M.binary_file_size()"), child.lua_get("_G.fsize"))
	end,

	bi_kibibytes = function()
		local text = vim.deepcopy(MiniTest.current.case.data.fsize_text)
		for _ = 1, 10 do
			table.insert(text, text[1])
		end
		child.api.nvim_buf_set_text(0, 0, 0, 0, 0, text)
		child.cmd("w")
		child.lua([[_G.fsize.size = 1.07; _G.fsize.suffix = "KiB"]])
		eq(child.lua("return M.binary_file_size()"), child.lua_get("_G.fsize"))
	end,

	bi_mibibytes = function()
		local text = vim.deepcopy(MiniTest.current.case.data.fsize_text)
		for _ = 1, 10500 do
			table.insert(text, text[1])
		end
		child.api.nvim_buf_set_text(0, 0, 0, 0, 0, text)
		child.cmd("w")
		child.lua([[_G.fsize.size = 1; _G.fsize.suffix = "MiB"]])
		eq(child.lua("return M.binary_file_size()"), child.lua_get("_G.fsize"))
	end
})

-- IS FOCUSED
T["is_focused"] = MiniTest.new_set({
	hooks = {
		pre_once = function()
			child.start({ "-u", "tests/minimal_init.lua" })
			child.lua([[M = require("everybody-wants-that-line.utils.util")]])
			child.cmd([[e lua/everybody-wants-that-line.lua | split tests/utils/test_util.lua]])
			child.cmd([[set laststatus=2]])
		end,
		post_once = function()
			child.stop()
		end,
	}
}, {
	focused = function()
		local winids = child.api.nvim_list_wins()
		for i, v in ipairs(winids) do
			local stl = child.api.nvim_eval_statusline([[%{%v:lua.M.is_focused()%}]], { winid = v })
			if i == 1 then
				eq(stl.str, stl.str:find("v:") == nil and "true" or "v:true")
			elseif i == 2 then
				eq(stl.str, stl.str:find("v:") == nil and "false" or "v:false")
			end
		end
	end,
})

-- BUFFER NUMBER
T["get_bufnr"] = MiniTest.new_set({
	hooks = {
		pre_once = function()
			child.start({ "-u", "tests/minimal_init.lua" })
			child.lua([[M = require("everybody-wants-that-line.utils.util")]])
			child.cmd([[e lua/everybody-wants-that-line.lua]])
		end,
		post_once = function()
			child.stop()
		end,
	}
}, {
	equal = function()
		local bufid = child.api.nvim_get_current_buf()
		eq(child.lua("return M.get_bufnr()"), bufid)
	end,
})

return T
