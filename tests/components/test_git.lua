local eq = MiniTest.expect.equality
local child = MiniTest.new_child_neovim()

local poke_eventloop = function()
	child.api.nvim_eval('1')
end
local sleep = function(ms)
	vim.loop.sleep(ms)
	poke_eventloop()
end

local match_basedir = function(v)
	---@type string
	local cwd = child.fn.getcwd()
	return cwd:match(v)
end

local T = MiniTest.new_set({
	hooks = {
		pre_once = function()
			child.start({ "-u", "tests/minimal_init.lua" })
			child.fn.system([[cd dependencies && git init -b "test_branch" && echo "" >> test_file && git add test_file && git commit -m "init"]])
		end,
		pre_case = function()
			sleep(1000)
			child.restart({ "-u", "tests/minimal_init.lua" })
			child.lua([[require("everybody-wants-that-line").setup()]])
			child.lua([[M = require("everybody-wants-that-line.components.git")]])
		end,
		post_once = function()
			child.cmd("cd ..")
			child.fn.system("cd dependencies && rm -rf .git test_file")
			child.stop()
		end,
	},
})

T["cache.branch"] = function()
	child.cmd("cd dependencies")
	child.cmd("e test_file")
	eq(match_basedir("dependencies"), "dependencies")
	MiniTest.expect.no_equality(string.find(child.api.nvim_buf_get_name(0), "dependencies/test_file"), nil)
	eq(child.lua_get("M.cache.branch"), "test_branch")
end

T["cache.diff_info"] = function()
	child.cmd("cd dependencies")
	child.cmd("e test_file")
	eq(match_basedir("dependencies"), "dependencies")
	MiniTest.expect.no_equality(string.find(child.api.nvim_buf_get_name(0), "dependencies/test_file"), nil)
	child.type_keys("i", "test line", "<Esc>")
	child.type_keys("o", "next line", "<Esc>")
	--child.api.nvim_buf_set_text(0, 0, 0, 0, 0, { "text" })
	child.cmd("w")
	eq(child.fn.system("type grep"), "grep is /usr/bin/grep\n")
	eq(child.fn.system("type sed"), "sed is /usr/bin/sed\n")
	eq(child.fn.system("git diff --stat"), "")
	---@type git_cache_diffinfo
	local diff_info = {
		insertions = 2,
		deletions = 1,
	}
	eq(child.lua_get("M.cache.diff_info"), diff_info)
end

return T
