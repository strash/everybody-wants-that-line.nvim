local M = {}

M.cache = {
	branch = "",
	---`{ "0", "0" }` where the first string is __insertions__
	---and the second one is __deletions__.
	---@type string[]
	diff_info = { "0", "0" },
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

function M.set_git_branch()
	M.cache.branch = get_git_branch()
end

function M.set_diff_info()
	M.cache.diff_info = get_diff_info()
end

return M
