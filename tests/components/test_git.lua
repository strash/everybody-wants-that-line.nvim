local eq = MiniTest.expect.equality
local child = MiniTest.new_child_neovim()

local T = MiniTest.new_set({
	hooks = {
		pre_once = function()
			child.start({ "-u", "tests/minimal_init.lua" })
			child.fn.system([[cd dependencies && git init -b "test_branch" && echo "" >> test_file && git add test_file && git commit -m "init"]])
		end,
		pre_case = function()
			child.restart({ "-u", "tests/minimal_init.lua" })
			child.lua([[require("everybody-wants-that-line").setup()]])
			child.lua([[M = require("everybody-wants-that-line.components.git")]])
			child.cmd("cd dependencies | e test_file")
		end,
		post_once = function()
			child.cmd("cd ..")
			child.fn.system("cd dependencies && rm -rf .git test_file")
			child.stop()
		end,
	},
})

T["cache.branch"] = function()
	eq(child.lua_get("M.cache.branch"), "test_branch")
end

T["cache.diff_info"] = function()
	child.type_keys("i", "test line", "<Esc>")
	child.type_keys("o", "next line", "<Esc>")
	child.cmd("w")
	---@type git_cache_diffinfo
	local diff_info = {
		insertions = 2,
		deletions = 1,
	}
	eq(child.lua_get("M.cache.diff_info"), diff_info)
end

return T
