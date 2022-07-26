local UU = require("everybody-wants-that-line.utils.util")

local eq = MiniTest.expect.equality
local child = MiniTest.new_child_neovim()

local T = MiniTest.new_set({
	hooks = {
		pre_case = function()
			child.restart({ "-u", "tests/minimal_init.lua" })
			child.cmd("set laststatus=3")
			child.lua([[M = require("everybody-wants-that-line.components.buffer")]])
		end,
		post_once = function()
			child.stop()
		end,
	},
})

T["get_buffer_preffix"] = function()
	child.lua([[require("everybody-wants-that-line").setup({
		buffer = {
			prefix = "Buffer"
		}
	}) ]])
	eq(child.lua("return M.get_buffer_prefix()"), "%#" .. UU.prefix .. "Fg60#Buffer %*")
end

T["get_buf_modflag"] = MiniTest.new_set({}, {
	no_changes = function()
		child.lua([[require("everybody-wants-that-line").setup()]])
		eq(child.lua([[return M.get_buf_modflag()]]), " ")
	end,
	modifiable = function()
		child.cmd("hi " .. UU.prefix .. "DiffAdd guifg=#1C4915 guibg=#000000")
		child.lua([[require("everybody-wants-that-line").setup()]])
		child.api.nvim_buf_set_text(0, 0, 0, 0, 0, { "text" })
		eq(child.lua([[return M.get_buf_modflag()]]), "%#" .. UU.prefix .. "FgDiffAdd#+%*")
	end,
	not_modifiable = function()
		child.lua([[require("everybody-wants-that-line").setup()]])
		child.cmd("h api")
		eq(child.lua([[return M.get_buf_modflag()]]), "%#" .. UU.prefix .. "FgDiffDelete#-%*")
	end,
})

T["get_buf_nr"] = MiniTest.new_set({}, {
	with_prefix = function()
		child.lua([[require("everybody-wants-that-line").setup({
			buffer = {
				max_symbols = 5,
				symbol = "a",
			}
		}) ]])
		eq(child.lua([[return M.get_buf_nr(require("everybody-wants-that-line.settings").opt.buffer)]]),
			{ prefix = "aaaa", nr = "1", bufnr = 1 })
	end,
	without_prefix = function()
		child.lua([[require("everybody-wants-that-line").setup({
			buffer = {
				max_symbols = 0,
				symbol = "g",
			}
		}) ]])
		eq(child.lua([[return M.get_buf_nr(require("everybody-wants-that-line.settings").opt.buffer)]]),
			{ prefix = "", nr = "1", bufnr = 1 })
	end,
})

return T
