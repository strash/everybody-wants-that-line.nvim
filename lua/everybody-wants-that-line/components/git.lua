local M = {}

---@alias git_cache_diffinfo { insertions: integer, deletions: integer }

---@class git_cache
---@field branch string
---@field diff_info git_cache_diffinfo

---@type git_cache
M.cache = {
	branch = "",
	diff_info = {
		insertions = 0,
		deletions = 0
	},
}

---Sets branch name
function M.set_git_branch()
	local branch = ""
	if vim.fn.isdirectory(".git") ~= 0 then
		branch = vim.fn.system("git branch --show-current | tr -d '\n'")
	end
	M.cache.branch = branch
end

---Sets diff info
function M.set_diff_info()
	local insertions = 0
	local deletions = 0
	if vim.fn.isdirectory(".git") ~= 0 then
		local stat = vim.fn.system("git diff --stat | grep -F changed | sed 's/.*ed, //'")
		for n in stat:gmatch("%d+ %w+") do
			if n:find("insert") ~= nil then
				insertions = tonumber(n:match("%d+")) --[[@as integer]]
			elseif n:find("delet") ~= nil then
				deletions = tonumber(n:match("%d+")) --[[@as integer]]
			end
		end
	end
	---@cast insertions integer
	M.cache.diff_info.insertions = insertions
	---@cast deletions integer
	M.cache.diff_info.deletions = deletions
end

return M
