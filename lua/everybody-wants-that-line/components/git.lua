local M = {}

M.cache = {
	branch = "",
	---`{ "0", "0" }` where the first string is __insertions__
	---and the second one is __deletions__.
	---@type string[]
	diff_info = {},
}

---Returns branch name
---@return string
local function get_git_branch()
	local branch = ""
	if vim.fn.isdirectory(".git") ~= 0 then
		branch = vim.fn.system("git branch --show-current | tr -d '\n'")
	end
	return branch
end

---Returns diff info.
---`{ "0", "0" }` where the first string is __insertions__
---and the second one is __deletions__.
---@return string[]
local function get_diff_info()
	local insertions = ""
	local deletions = ""
	if vim.fn.isdirectory(".git") ~= 0 then
		local stat = vim.fn.system("git diff HEAD --stat | grep -F changed | sed 's/.*ed, //'")
		for n in stat:gmatch("%d+ %w+") do
			if n:find("insert") ~= nil then
				insertions = n:match("%d+")
			elseif n:find("delet") ~= nil then
				deletions = n:match("%d+")
			end
		end
	end
	return { insertions, deletions }
end

---Set auto commands
---@param group_name string
---@param cb function
function M.setup_autocmd(group_name, cb)
	-- branch name
	vim.api.nvim_create_autocmd({
		"BufEnter",
	}, {
		pattern = "*",
		callback = function()
			M.cache.branch = get_git_branch()
			cb()
		end,
		group = group_name,
	})

	-- diff info
	vim.api.nvim_create_autocmd({
		"BufWritePost",
		"BufReadPost",
	}, {
		pattern = "*",
		callback = function()
			M.cache.diff_info = get_diff_info()
			cb()
		end,
		group = group_name,
	})

	-- neogit commit complete
	vim.api.nvim_create_autocmd('User', {
		pattern = 'NeogitCommitComplete',
		group = group_name,
		callback = function()
			M.cache.diff_info = get_diff_info()
			cb()
		end,
	})

	-- neogit push complete
	vim.api.nvim_create_autocmd('User', {
		pattern = 'NeogitPushComplete',
		group = group_name,
		callback = function()
			M.cache.diff_info = get_diff_info()
			cb()
		end,
	})

	-- both
	vim.api.nvim_create_autocmd({
		"VimEnter",
		"FocusGained",
	}, {
		pattern = "*",
		callback = function()
			M.cache.branch = get_git_branch()
			M.cache.diff_info = get_diff_info()
			cb()
		end,
		group = group_name,
	})
end

return M
