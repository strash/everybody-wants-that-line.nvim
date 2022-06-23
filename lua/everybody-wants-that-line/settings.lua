local M = {
	buffer = {
		symbol = "0",
		max_symbols = 5,
	},
	separator = "│",
}

function M:setup(opts)
	if opts ~= nil and type(opts) == "table" then
		for k, v in pairs(opts) do
			if type(v) == "table" then
				for vk, vv in pairs(v) do
					if self[k][vk] ~= nil and type(self[k][vk]) == type(vv) then
						self[k][vk] = vv
					end
				end
			else
				if self[k] ~= nil and type(self[k]) == type(v) and k ~= "setup" then
					self[k] = v
				end
			end
		end
	end
end

return M
