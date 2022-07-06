local M = {
	buffer = {
		prefix = "b",
		symbol = "0",
		max_symbols = 5,
	},
	separator = "│",
}

function M.setup(opts)
	if opts ~= nil and type(opts) == "table" then
		for k, v in pairs(opts) do
			if type(v) == "table" then
				for vk, vv in pairs(v) do
					if M[k][vk] ~= nil and type(M[k][vk]) == type(vv) then
						M[k][vk] = vv
					end
				end
			else
				if M[k] ~= nil and type(M[k]) == type(v) and k ~= "setup" then
					M[k] = v
				end
			end
		end
	end
end

return M
