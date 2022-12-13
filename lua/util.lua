local Util = {}

function Util.default_tbl(opts, default)
	opts = opts or {}
	return default and vim.tbl_deep_extend("force", default, opts) or opts
end

function Util.keymap(mode, map, cmd, opts)
	if type(opts) == "string" then opts = { desc = opts } end
	local options = { noremap = true, silent = true }
	if opts then options = vim.tbl_extend("force", options, opts) end
	vim.keymap.set(mode, map, cmd, options)
end

--- Get highlight properties for a given highlight name
-- @param name highlight group name
-- @return table of highlight group properties
function Util.get_hl_group(name, fallback)
	if vim.fn.hlexists(name) == 1 then
		local hl = vim.api.nvim_get_hl_by_name(name, vim.o.termguicolors)
		local old_true_val = hl[true]
		hl[true] = nil
		if not vim.tbl_isempty(hl) then
			hl[true] = old_true_val
			if not hl["foreground"] then hl["foreground"] = "NONE" end
			if not hl["background"] then hl["background"] = "NONE" end
			hl.fg, hl.bg, hl.sp = hl.foreground, hl.background, hl.special
			hl.ctermfg, hl.ctermbg = hl.foreground, hl.background
			return hl
		end
	end
	return fallback
end

function Util.filetype_color(self)
	local devicons_avail, devicons = pcall(require, "nvim-web-devicons")
	if not devicons_avail then return {} end
	local _, color = devicons.get_icon_color(
		vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self and self.bufnr or 0), ":t"),
		nil,
		{ default = true }
	)
	return { fg = color }
end

--- Trim a string or return nil
-- @param str the string to trim
-- @return a trimmed version of the string or nil if the parameter isn't a string
function Util.trim_or_nil(str) return type(str) == "string" and vim.trim(str) or nil end

--- Add left and/or right padding to a string
-- @param str the string to add padding to
-- @param padding a table of the format `{ left = 0, right = 0}` that defines the number of spaces to include to the left and the right of the string
-- @return the padded string
function Util.pad_string(str, padding)
	padding = padding or {}
	return str
		and str ~= ""
		and string.rep(" ", padding.left or 0) .. str .. string.rep(" ", padding.right or 0)
		or ""
end

Util.get_separator = function()
  return '/'
end

Util.strip_trailing_sep = function(path)
  local res, _ = string.gsub(path, util.get_separator() .. '$', '', 1)
  return res
end

Util.join_paths = function(...)
  local separator = Util.get_separator()
  return table.concat({ ... }, separator)
end

return Util
