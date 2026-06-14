local M = {}

local state = {
	register = "q",
	counter = 1,
}

local region_namespace = vim.api.nvim_create_namespace("my_macro_region")

local function termcodes(keys)
	return vim.api.nvim_replace_termcodes(keys, true, false, true)
end

local function feed(keys)
	vim.api.nvim_feedkeys(termcodes(keys), "ni", false)
end

local function in_insert_mode()
	return vim.api.nvim_get_mode().mode:match("^[iR]") ~= nil
end

local function return_to_insert()
	vim.schedule(function()
		if vim.api.nvim_get_mode().mode:match("^[n]") ~= nil then
			vim.cmd.startinsert()
		end
	end)
end

local function notify(message, level)
	vim.notify(message, level or vim.log.levels.INFO, { title = "macro" })
end

function M.is_recording()
	return vim.fn.reg_recording() ~= ""
end

function M.start(register)
	if M.is_recording() then
		notify("Already recording @" .. vim.fn.reg_recording(), vim.log.levels.WARN)
		return
	end

	state.register = register or state.register
	if in_insert_mode() then
		feed("<Esc>q" .. state.register .. "i")
	else
		feed("q" .. state.register)
	end
	notify("Recording @" .. state.register)
end

function M.stop()
	if not M.is_recording() then
		notify("No macro is being recorded", vim.log.levels.WARN)
		return false
	end

	if in_insert_mode() then
		feed("<Esc>qi")
	else
		feed("q")
	end
	notify("Recorded @" .. state.register)
	return true
end

function M.start_or_insert_counter()
	if M.is_recording() then
		feed(tostring(state.counter))
		state.counter = state.counter + 1
	else
		M.start()
	end
end

function M.end_or_call()
	if M.is_recording() then
		M.stop()
	else
		M.call()
	end
end

function M.call()
	if vim.fn.getreg(state.register) == "" then
		notify("No macro in @" .. state.register, vim.log.levels.WARN)
		return
	end

	if in_insert_mode() then
		feed("<Esc>@" .. state.register .. "i")
	else
		feed("@" .. state.register)
	end
end

function M.end_and_call()
	if M.is_recording() then
		if in_insert_mode() then
			feed("<Esc>q@" .. state.register .. "i")
		else
			feed("q@" .. state.register)
		end
	else
		M.call()
	end
end

function M.query()
	notify("kbd-macro-query has no direct Neovim equivalent", vim.log.levels.WARN)
end

function M.edit()
	vim.ui.input({
		prompt = "@" .. state.register .. " macro> ",
		default = vim.fn.getreg(state.register),
	}, function(input)
		if input ~= nil then
			vim.fn.setreg(state.register, input)
			notify("Updated @" .. state.register)
		end
	end)
end

function M.apply_to_region_lines()
	if vim.fn.getreg(state.register) == "" then
		notify("No macro in @" .. state.register, vim.log.levels.WARN)
		return
	end

	local start_line = vim.fn.line("'<")
	local end_line = vim.fn.line("'>")
	if start_line <= 0 or end_line <= 0 then
		notify("Select lines before applying a macro", vim.log.levels.WARN)
		return
	end

	local first = math.min(start_line, end_line)
	local last = math.max(start_line, end_line)
	local bufnr = vim.api.nvim_get_current_buf()
	local marks = {}

	vim.api.nvim_buf_clear_namespace(bufnr, region_namespace, 0, -1)
	for line = first, last do
		local id = vim.api.nvim_buf_set_extmark(bufnr, region_namespace, line - 1, 0, {
			right_gravity = false,
		})
		table.insert(marks, id)
	end

	for index = #marks, 1, -1 do
		local pos = vim.api.nvim_buf_get_extmark_by_id(bufnr, region_namespace, marks[index], {})
		if #pos == 2 then
			vim.api.nvim_win_set_cursor(0, { pos[1] + 1, 0 })
			vim.cmd("normal! @" .. state.register)
		end
	end

	vim.api.nvim_buf_clear_namespace(bufnr, region_namespace, 0, -1)
	return_to_insert()
end

function M.copy_to_register()
	vim.ui.input({ prompt = "copy @" .. state.register .. " to register> " }, function(input)
		if input and input ~= "" then
			vim.fn.setreg(input:sub(1, 1), vim.fn.getreg(state.register), vim.fn.getregtype(state.register))
			notify("Copied @" .. state.register .. " to @" .. input:sub(1, 1))
		end
	end)
end

return M
