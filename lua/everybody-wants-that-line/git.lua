local M = {}

M.cache = {
	branch = "",
	diff_info = {
		insertions = "",
		deletions = "",
	},
}

local function get_git_branch()
	local branch = ""
	if vim.fn.isdirectory(".git") ~= 0 then
		branch = vim.fn.system("git branch --show-current | tr -d '\n'")
	end
	return branch
end

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
function M.setup_autocmd(group_name)
	vim.api.nvim_create_autocmd({
		"VimEnter",
		"BufWritePost",
	}, {
		pattern = "*",
		callback = function()
			M.cache.diff_info = get_diff_info()
		end,
		group = group_name,
	})

	vim.api.nvim_create_autocmd({
		"VimEnter",
		"BufEnter",
		"FocusGained",
	}, {
		pattern = "*",
		callback = function()
			M.cache.branch = get_git_branch()
		end,
		group = group_name,
	})
end

return M
