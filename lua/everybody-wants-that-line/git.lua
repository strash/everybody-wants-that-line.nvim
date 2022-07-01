local M = {}

M.cache = {
	branch = "",
	diff_info = {
		insertions = "",
		deletions = "",
	},
}

-- getting branch name
local function get_git_branch()
	local branch = ""
	if vim.fn.isdirectory(".git") ~= 0 then
		branch = vim.fn.system("git branch --show-current | tr -d '\n'")
	end
	return branch
end

-- getting diff info numbers
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
	return { insertions = insertions, deletions = deletions }
end

-- auto commands
function M.setup_autocmd(group_name, callback)
	-- branch name
	vim.api.nvim_create_autocmd({
		"BufEnter",
	}, {
		pattern = "*",
		callback = function()
			M.cache.branch = get_git_branch()
			callback()
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
			callback()
		end,
		group = group_name,
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
			callback()
		end,
		group = group_name,
	})
end

return M
