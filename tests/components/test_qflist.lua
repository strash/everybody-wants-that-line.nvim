local eq = MiniTest.expect.equality
local child = MiniTest.new_child_neovim()

local T = MiniTest.new_set({
	hooks = {
		pre_case = function()
			child.restart({ "-u", "tests/minimal_init.lua" })
			child.lua([[require("everybody-wants-that-line").setup()]])
			child.lua([[M = require("everybody-wants-that-line.components.qflist")]])
		end,
		post_once = function()
			child.stop()
		end,
	},
})

T["is_qflist_empty"] = function()
	eq(child.lua_get("M.is_qflist_empty()"), true)
end

T["is_qflist_open"] = function()
	child.cmd("cope")
	eq(child.lua_get("M.is_qflist_open()"), true)
end

T["get_qflist_winid"] = function()
	child.cmd("cope")
	eq(child.lua_get("M.get_qflist_winid()"), child.api.nvim_get_current_win())
end

T["qf"] = MiniTest.new_set({
	hooks = {
		pre_case = function()
			child.restart({ "-u", "tests/minimal_init.lua" })
			child.lua([[require("everybody-wants-that-line").setup()]])
			child.lua([[M = require("everybody-wants-that-line.components.qflist")]])
			child.cmd("e dependencies/test_file | w")
			child.type_keys("i", "test line", "<Enter>", "another line", "<Enter>", "and third line", "<Esc>")
			child.cmd("w | vim line dependencies/test_file | cn")
		end,
		post_case = function()
			child.fn.system("rm dependencies/test_file")
		end,
		post_once = function()
			child.stop()
		end,
	},
}, {
	get_qflist_idx = function()
		eq(child.lua_get("M.get_qflist_idx()"), 2)
	end,
	get_entries_count = function()
		eq(child.lua_get("M.get_entries_count()"), 3)
	end,
	get_files_w_entries_count = function()
		eq(child.lua_get("M.get_files_w_entries_count()"), 1)
	end,
})

return T
