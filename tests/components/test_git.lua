local eq = MiniTest.expect.equality
local child = MiniTest.new_child_neovim()

local T = MiniTest.new_set({
	hooks = {
		pre_once = function()
			child.start({ "-u", "tests/minimal_init.lua" })
			child.fn.system([[cd dependencies && git init -b "test_branch" && echo "" >> test_file && git add test_file && git commit -m "init"]])
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
	child.api.nvim_buf_set_text(0, 0, 0, 0, 0, { "text" })
	child.cmd("w")
	---@type git_cache_diffinfo
	local diff_info = {
		insertions = 1,
		deletions = 1,
	}
	eq(child.lua_get("M.cache.diff_info"), diff_info)
end

return T
