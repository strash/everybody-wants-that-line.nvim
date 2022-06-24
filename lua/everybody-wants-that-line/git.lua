local M = {}

function M.get_git_branch()
	local branch = ""
	if vim.fn.isdirectory(".git") ~= 0 then
		branch = vim.fn.system("git branch --show-current | tr -d '\n'")
	end
	return branch
end

function M.get_diff_info()
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
	return insertions, deletions
end

return M
