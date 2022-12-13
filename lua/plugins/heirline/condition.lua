local M = {}
local function pattern_match(str, pattern_list)
	for _, pattern in ipairs(pattern_list) do
		if str:find(pattern) then return true end
	end
	return false
end

local buf_matchers = {
	filetype = function(pattern_list) return pattern_match(vim.bo.filetype, pattern_list) end,
	buftype = function(pattern_list) return pattern_match(vim.bo.buftype, pattern_list) end,
	bufname = function(pattern_list) return pattern_match(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t"),
			pattern_list)
	end,
}
--- A condition function if the window is currently active
-- @return boolean of wether or not the window is currently actie
-- @usage local heirline_component = { provider = "Example Provider", condition = M.is_active }
function M.is_active() return vim.api.nvim_get_current_win() == tonumber(vim.g.actual_curwin) end

--- A condition function if the buffer filetype,buftype,bufname match a pattern
-- @return boolean of wether or not LSP is attached
-- @usage local heirline_component = { provider = "Example Provider", condition = function() return M.buffer_matches { buftype = { "terminal" } } end }
function M.buffer_matches(patterns)
	for kind, pattern_list in pairs(patterns) do
		if buf_matchers[kind](pattern_list) then return true end
	end
	return false
end

--- A condition function if a macro is being recorded
-- @return boolean of wether or not a macro is currently being recorded
-- @usage local heirline_component = { provider = "Example Provider", condition = M.is_macro_recording }
function M.is_macro_recording() return vim.fn.reg_recording() ~= "" end

--- A condition function if search is visible
-- @return boolean of wether or not searching is currently visible
-- @usage local heirline_component = { provider = "Example Provider", condition = M.is_hlsearch }
function M.is_hlsearch() return vim.v.hlsearch ~= 0 end

--- A condition function if the current file is in a git repo
-- @return boolean of wether or not the current file is in a git repo
-- @usage local heirline_component = { provider = "Example Provider", condition = M.is_git_repo }
function M.is_git_repo() return vim.b.gitsigns_head or vim.b.gitsigns_status_dict end

--- A condition function if there are any git changes
-- @return boolean of wether or not there are any git changes
-- @usage local heirline_component = { provider = "Example Provider", condition = M.git_changed }
function M.git_changed()
	local git_status = vim.b.gitsigns_status_dict
	return git_status and (git_status.added or 0) + (git_status.removed or 0) + (git_status.changed or 0) > 0
end

--- A condition function if the current buffer is modified
-- @return boolean of wether or not the current buffer is modified
-- @usage local heirline_component = { provider = "Example Provider", condition = M.file_modified }
function M.file_modified(bufnr) return vim.bo[bufnr or 0].modified end

--- A condition function if the current buffer is read only
-- @return boolean of wether or not the current buffer is read only or not modifiable
-- @usage local heirline_component = { provider = "Example Provider", condition = M.file_read_only }
function M.file_read_only(bufnr)
	local buffer = vim.bo[bufnr or 0]
	return not buffer.modifiable or buffer.readonly
end

--- A condition function if the current file has any diagnostics
-- @return boolean of wether or not the current file has any diagnostics
-- @usage local heirline_component = { provider = "Example Provider", condition = M.has_diagnostics }
function M.has_diagnostics()
	return vim.g.status_diagnostics_enabled and #vim.diagnostic.get(0) > 0
end

--- A condition function if there is a defined filetype
-- @return boolean of wether or not there is a filetype
-- @usage local heirline_component = { provider = "Example Provider", condition = M.has_filetype }
function M.has_filetype()
	return vim.fn.empty(vim.fn.expand "%:t") ~= 1 and vim.bo.filetype and vim.bo.filetype ~= ""
end

--- A condition function if Aerial is available
-- @return boolean of wether or not aerial plugin is installed
-- @usage local heirline_component = { provider = "Example Provider", condition = M.aerial_available }
-- function M.aerial_available() return astronvim.is_available "aerial.nvim" end
function M.aerial_available() return package.loaded["aerial"] end

--- A condition function if LSP is attached
-- @return boolean of wether or not LSP is attached
-- @usage local heirline_component = { provider = "Example Provider", condition = M.lsp_attached }
function M.lsp_attached() return next(vim.lsp.buf_get_clients()) ~= nil end

--- A condition function if treesitter is in use
-- @return boolean of wether or not treesitter is active
-- @usage local heirline_component = { provider = "Example Provider", condition = M.treesitter_available }
function M.treesitter_available()
	return package.loaded["nvim-treesitter"] and require("nvim-treesitter.parsers").has_parser()
end

return M
