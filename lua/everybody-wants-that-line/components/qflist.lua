local M = {}

---@type table[]
local qflist = {}

---Sets quickfix list
function M.set_qflist()
	qflist = vim.fn.getqflist() or {}
	local idx = 1
	for _, i in ipairs(qflist) do
		if i.valid == 1 then
			i["_idx"] = idx
			idx = idx + 1
		end
	end
end

---Check if quickfix list is empty
---@return boolean
function M.is_qflist_empty()
	return #qflist == 0
end

---Returns quickfix list winid
---@return integer
function M.get_qflist_winid()
	return vim.fn.getqflist({ winid = true }).winid
end

---Check if quickfix list is open
---@return boolean
function M.is_qflist_open()
	return M.get_qflist_winid() ~= 0
end

---Get the current entry index. Starts from `1`
---@return integer
function M.get_qflist_idx()
	local idx = vim.fn.getqflist({ idx = 0 }).idx
	if #qflist > 0 and idx ~= nil and qflist[idx]["_idx"] ~= nil then
		return qflist[idx]["_idx"]
	else
		return 0
	end
end

---Returns the number of errors in quickfix
---@return integer
function M.get_entries_count()
	local count = 0
	if #qflist > 0 then
		for _, i in ipairs(qflist) do
			if i.valid == 1 then
				count = count + 1
			end
		end
	end
	return count
end

---Returns the number of files in quickfix list
---@return integer
function M.get_files_w_entries_count()
	local buffers = {}
	if #qflist > 0 then
		for _, t in ipairs(qflist) do
			if t.valid == 1 and #buffers == 0 or t.valid == 1 and buffers[#buffers] ~= t.bufnr then
				table.insert(buffers, t.bufnr)
			end
		end
	end
	return #buffers
end

return M
