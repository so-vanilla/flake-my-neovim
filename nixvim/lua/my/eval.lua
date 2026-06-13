local M = {}

local function eval_lua(source)
	local chunk, err = load("return " .. source, "my-neovim-eval", "t", _G)
	if not chunk then
		chunk, err = load(source, "my-neovim-eval", "t", _G)
	end
	if not chunk then
		vim.notify(err, vim.log.levels.ERROR)
		return
	end

	local ok, result = pcall(chunk)
	if not ok then
		vim.notify(result, vim.log.levels.ERROR)
		return
	end

	if result ~= nil then
		vim.print(result)
	end
end

function M.lua()
	vim.ui.input({ prompt = "lua> " }, function(input)
		if input and input ~= "" then
			eval_lua(input)
		end
	end)
end

return M
