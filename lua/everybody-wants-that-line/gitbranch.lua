local M = {}

M.get_git_branch = function ()
	local branch = ""
	if vim.fn.isdirectory ".git" ~= 0 then
		branch = vim.fn.system("git branch --show-current | tr -d '\n'")
	end
	return branch
end

return M
