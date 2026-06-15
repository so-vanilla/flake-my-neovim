local M = {}

local function is_special_ui()
	local ok, special_ui = pcall(require, "my.special_ui")
	return ok and special_ui.is_special()
end

local function call(name, ...)
	if is_special_ui() then
		return
	end

	local ok, softpair = pcall(require, "softpair")
	if not ok or type(softpair[name]) ~= "function" then
		return
	end

	return softpair[name](...)
end

local function matching_pair()
	if is_special_ui() then
		return
	end

	local ok_sexp, sexp = pcall(require, "softpair.sexp")
	local ok_doc, doc = pcall(require, "softpair.doc")
	if not ok_sexp or not ok_doc then
		return
	end

	local text = doc.text()
	local point = doc.point()
	local target = sexp.match_forward(text, point) or sexp.match_backward(text, point)
	if not target then
		return
	end

	doc.set_point(target)
	return target
end

local function match_or_call(name)
	return matching_pair() or call(name)
end

function M.forward_delete_char()
	return call("forward_delete_char")
end

function M.kill_line()
	return call("kill_line")
end

function M.backward_kill_line()
	return call("backward_kill_line")
end

function M.backward_kill_word()
	return call("backward_kill_word")
end

function M.forward_kill_word()
	return call("forward_kill_word")
end

function M.forward_sexp()
	return match_or_call("forward_sexp")
end

function M.backward_sexp()
	return match_or_call("backward_sexp")
end

function M.beginning_of_sexp()
	return call("beginning_of_sexp")
end

function M.end_of_sexp()
	return call("end_of_sexp")
end

function M.syntactic_backward_punct()
	return call("syntactic_backward_punct")
end

function M.syntactic_forward_punct()
	return call("syntactic_forward_punct")
end

function M.force_delete()
	return call("force_delete")
end

function M.kill_active_region(visual_mode)
	return call("kill_active_region", visual_mode)
end

return M
