local child = MiniTest.new_child_neovim()
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({
	hooks = {
		pre_once = function()
			child.restart({ "-u", "tests/minimal_init.lua" })
			child.fn.system("touch dependencies/test_file")
			child.cmd("e dependencies/test_file")
			child.lua([[require("everybody-wants-that-line").setup()]])
			child.lua([[M = require("everybody-wants-that-line.components.filepath")]])
		end,
		post_once = function()
			child.fn.system("rm dependencies/test_file")
			child.stop()
		end,
	},
})

T["get_filepath"] = function()
	child.lua([[require("everybody-wants-that-line").setup({
		filepath = {
			path = "tail",
		},
	})]])
	local fullpath = child.api.nvim_buf_get_name(0)
	-- it could be anything, so ...
	local p = string.sub(fullpath, 0, #fullpath - #"dependencies/test_file")
	---@type filepath_cache_path_parts
	local filepath = {
		full = {
			filename = "test_file",
			path = p .. "dependencies/",
			shorten = vim.fn.pathshorten(p .. "dependencies/"),
		},
		relative = {
			filename = "test_file",
			path = "./dependencies/",
			shorten = "./d/",
		}
	}
	eq(child.lua_get("M.get_filepath(" .. vim.api.nvim_get_current_buf() .. ")"), filepath)
end

return T
