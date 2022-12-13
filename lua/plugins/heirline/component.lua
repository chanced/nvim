local util = require("util")
local icons = require("icons")
local condition = require("plugins.heirline.condition")
local tools = require("plugins.heirline.tools")
local hl = require("plugins.heirline.hl")
local M = { component = {}, provider = {} }
--- A Heirline component for filling in the empty space of the bar
-- @return The heirline component table
-- @usage local heirline_component = M.component.fill()
function M.component.fill() return { provider = M.provider.fill() } end

--- A function to build a set of children components for an entire file information section
-- @param opts options for configuring file_icon, filename, filetype, file_modified, file_read_only, and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = M.component.file_info()
function M.component.file_info(opts)
	opts = util.default_tbl(opts, {
		file_icon = { hl = util.filetype_color, padding = { left = 1, right = 1 } },
		filename = {},
		file_modified = { padding = { left = 1 } },
		file_read_only = { padding = { left = 1 } },
		surround = {
			separator = "left",
			color = "file_info_bg",
			condition = condition.has_filetype,
		},
		hl = { fg = "file_info_fg" },
	})
	return M.component.builder(M.provider.setup(opts, {
		"file_icon",
		"unique_path",
		"filename",
		"filetype",
		"file_modified",
		"file_read_only",
		"close_button",
	}))
end

--- A function to build a set of children components for an entire navigation section
-- @param opts options for configuring ruler, percentage, scrollbar, and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = M.component.nav()
function M.component.nav(opts)
	opts = util.default_tbl(opts, {
		ruler = {},
		percentage = { padding = { left = 1 } },
		scrollbar = { padding = { left = 1 }, hl = { fg = "scrollbar" } },
		surround = { separator = "right", color = "nav_bg" },
		hl = { fg = "nav_fg" },
		update = { "CursorMoved", "BufEnter" },
	})
	return M.component.builder(M.provider.setup(opts, { "ruler", "percentage", "scrollbar" }))
end

--- A function to build a set of children components for a macro recording section
-- @param opts options for configuring macro recording and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = M.component.macro_recording()
function M.component.macro_recording(opts)
	opts = util.default_tbl(opts, {
		macro_recording = { icon = { kind = "MacroRecording", padding = { right = 1 } } },
		surround = {
			separator = "center",
			color = "macro_recording_bg",
			condition = condition.is_macro_recording,
		},
		hl = { fg = "macro_recording_fg", bold = true },
		update = { "RecordingEnter", "RecordingLeave" },
	})
	return M.component.builder(M.provider.setup(opts, { "macro_recording" }))
end

--- A function to build a set of children components for information shown in the cmdline
-- @param opts options for configuring macro recording, search count, and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = M.component.cmd_info()
function M.component.cmd_info(opts)
	opts = util.default_tbl(opts, {
		macro_recording = {
			icon = { kind = "MacroRecording", padding = { right = 1 } },
			condition = condition.is_macro_recording,
			update = { "RecordingEnter", "RecordingLeave" },
		},
		search_count = {
			icon = { kind = "Search", padding = { right = 1 } },
			padding = { left = 1 },
			condition = condition.is_hlsearch,
		},
		surround = {
			separator = "center",
			color = "cmd_info_bg",
			condition = function() return condition.is_hlsearch() or condition.is_macro_recording() end,
		},
		condition = function() return vim.opt.cmdheight:get() == 0 end,
		hl = { fg = "cmd_info_fg" },
	})
	return M.component.builder(M.provider.setup(opts, { "macro_recording", "search_count" }))
end

--- A function to build a set of children components for a mode section
-- @param opts options for configuring mode_text, paste, spell, and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = M.component.mode { mode_text = true }
function M.component.mode(opts)
	opts = util.default_tbl(opts, {
		mode_text = false,
		paste = false,
		spell = false,
		surround = { separator = "left", color = hl.mode_bg },
		hl = { fg = "bg" },
		update = "ModeChanged",
	})
	if not opts["mode_text"] then opts.str = { str = " " } end
	return M.component.builder(M.provider.setup(opts, { "mode_text", "str", "paste", "spell" }))
end

--- A function to build a set of children components for an LSP breadcrumbs section
-- @param opts options for configuring breadcrumbs and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = M.component.breadcumbs()
function M.component.breadcrumbs(opts)
	opts = util.default_tbl(opts, {
		padding = { left = 1 },
		condition = condition.aerial_available,
		update = "CursorMoved",
	})
	opts.init = tools.breadcrumbs(opts)
	return opts
end

--- A function to build a set of children components for a git branch section
-- @param opts options for configuring git branch and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = M.component.git_branch()
function M.component.git_branch(opts)
	opts = util.default_tbl(opts, {
		git_branch = { icon = { kind = "GitBranch", padding = { right = 1 } } },
		surround = {
			separator = "left",
			color = "git_branch_bg",
			condition = condition.is_git_repo,
		},
		hl = { fg = "git_branch_fg", bold = true },
		on_click = {
			name = "heirline_branch",
			callback = function()
				vim.defer_fn(function() require("telescope.builtin").git_branches() end, 100)
			end,
		},
		update = { "User", pattern = "GitSignsUpdate" },
		init = tools.update_events({ "BufEnter" }),
	})
	return M.component.builder(M.provider.setup(opts, { "git_branch" }))
end

--- A function to build a set of children components for a git difference section
-- @param opts options for configuring git changes and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = M.component.git_diff()
function M.component.git_diff(opts)
	opts = util.default_tbl(opts, {
		added = { icon = { kind = "GitAdd", padding = { left = 1, right = 1 } } },
		changed = { icon = { kind = "GitChange", padding = { left = 1, right = 1 } } },
		removed = { icon = { kind = "GitDelete", padding = { left = 1, right = 1 } } },
		hl = { fg = "git_diff_fg", bold = true },
		on_click = {
			name = "heirline_git",
			callback = function()
				vim.defer_fn(function() require("telescope.builtin").git_status() end, 100)
			end,
		},
		surround = {
			separator = "left",
			color = "git_diff_bg",
			condition = condition.git_changed,
		},
		update = { "User", pattern = "GitSignsUpdate" },
		init = tools.update_events({ "BufEnter" }),
	})
	return M.component.builder(
		M.provider.setup(opts, { "added", "changed", "removed" }, function(p_opts, provider)
			local out = M.provider.build(p_opts, provider)
			if out then
				out.provider = "git_diff"
				out.opts.type = provider
				out.hl = { fg = "git_" .. provider }
			end
			return out
		end)
	)
end

--- A function to build a set of children components for a diagnostics section
-- @param opts options for configuring diagnostic M.provider and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = M.component.diagnostics()
function M.component.diagnostics(opts)
	opts = util.default_tbl(opts, {
		ERROR = { icon = { kind = "DiagnosticError", padding = { left = 1, right = 1 } } },
		WARN = { icon = { kind = "DiagnosticWarn", padding = { left = 1, right = 1 } } },
		INFO = { icon = { kind = "DiagnosticInfo", padding = { left = 1, right = 1 } } },
		HINT = { icon = { kind = "DiagnosticHint", padding = { left = 1, right = 1 } } },
		surround = {
			separator = "left",
			color = "diagnostics_bg",
			condition = condition.has_diagnostics,
		},
		hl = { fg = "diagnostics_fg" },
		on_click = {
			name = "heirline_diagnostic",
			callback = function()
				vim.defer_fn(function() require("telescope.builtin").diagnostics() end, 100)
			end,
		},
		update = { "DiagnosticChanged", "BufEnter" },
	})
	return M.component.builder(
		M.provider.setup(opts, { "ERROR", "WARN", "INFO", "HINT" }, function(p_opts, provider)
			local out = M.provider.build(p_opts, provider)
			if out then
				out.provider = "diagnostics"
				out.opts.severity = provider
				out.hl = { fg = "diag_" .. provider }
			end
			return out
		end)
	)
end

--- A function to build a set of children components for a Treesitter section
-- @param opts options for configuring diagnostic M.provider and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = M.component.treesitter()
function M.component.treesitter(opts)
	opts = util.default_tbl(opts, {
		str = { str = "TS", icon = { kind = "ActiveTS" } },
		surround = {
			separator = "right",
			color = "treesitter_bg",
			condition = condition.treesitter_available,
		},
		hl = { fg = "treesitter_fg" },
		update = { "OptionSet", pattern = "syntax" },
		init = tools.update_events({ "BufEnter" }),
	})
	return M.component.builder(M.provider.setup(opts, { "str" }))
end

--- A function to build a set of children components for an LSP section
-- @param opts options for configuring lsp progress and client_name M.provider and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = M.component.lsp()
function M.component.lsp(opts)
	opts = util.default_tbl(opts, {
		lsp_progress = {
			str = "",
			padding = { right = 1 },
			update = { "User", pattern = { "LspProgressUpdate", "LspRequest" } },
		},
		lsp_client_names = {
			str = "LSP",
			update = { "LspAttach", "LspDetach", "BufEnter" },
			icon = { kind = "ActiveLSP", padding = { right = 2 } },
		},
		hl = { fg = "lsp_fg" },
		surround = {
			separator = "right",
			color = "lsp_bg",
			condition = condition.lsp_attached,
		},
		on_click = {
			name = "heirline_lsp",
			callback = function()
				vim.defer_fn(function() vim.cmd.LspInfo() end, 100)
			end,
		},
	})
	return M.component.builder(
		M.provider.setup(
			opts,
			{ "lsp_progress", "lsp_client_names" },
			function(p_opts, provider, i)
				return p_opts
					and {
						flexible = i,
						M.provider.build(p_opts, M.provider[provider](p_opts)),
						M.provider.build(p_opts, M.provider.str(p_opts)),
					}
					or false
			end
		)
	)
end

--- A general function to build a section of astronvim status M.provider with highlights, conditions, and section surrounding
-- @param opts a list of components to build into a section
-- @return The Heirline component table
-- @usage local heirline_component = Ms.builder({ { provider = "file_icon", opts = { padding = { right = 1 } } }, { provider = "filename" } })
function M.component.builder(opts)
	opts = util.default_tbl(opts, { padding = { left = 0, right = 0 } })
	local children = {}
	if opts.padding.left > 0 then -- add left padding
		table.insert(
			children,
			{ provider = util.pad_string(" ", { left = opts.padding.left - 1 }) }
		)
	end
	for key, entry in pairs(opts) do
		if type(key) == "number"
			and type(entry) == "table"
			and M.provider[entry.provider]
			and (entry.opts == nil or type(entry.opts) == "table")
		then
			entry.provider = M.provider[entry.provider](entry.opts)
		end
		children[key] = entry
	end
	if opts.padding.right > 0 then -- add right padding
		table.insert(
			children,
			{ provider = util.pad_string(" ", { right = opts.padding.right - 1 }) }
		)
	end
	return opts.surround
		and tools.surround(
			opts.surround.separator,
			opts.surround.color,
			children,
			opts.surround.condition
		)
		or children
end

--- Convert a component parameter table to a table that can be used with the component builder
-- @param opts a table of provider options
-- @param provider a provider in `astronvim.status.providers`
-- @return the provider table that can be used in `astronvim.status.component.builder`
function M.provider.build(opts, provider, _)
	return opts
		and {
			provider = provider,
			opts = opts,
			condition = opts.condition,
			on_click = opts.on_click,
			update = opts.update,
			hl = opts.hl,
		}
		or false
end

--- Convert key/value table of options to an array of providers for the component builder
-- @param opts the table of options for the components
-- @param providers an ordered list like array of providers that are configured in the options table
-- @param setup a function that takes provider options table, provider name, provider index and returns the setup provider table, optional, default is `M.provider.build_provider`
-- @return the fully setup options table with the appropriately ordered providers
function M.provider.setup(opts, providers, setup)
	setup = setup or M.provider.build
	for i, provider in ipairs(providers) do
		opts[i] = setup(opts[provider], provider, i)
	end
	return opts
end

local modes = require("plugins.heirline.modes")

-- @param str the string to stylize
-- @param opts options of `{ padding = { left = 0, right = 0 }, separator = { left = "|", right = "|" }, show_empty = false, icon = { kind = "NONE", padding = { left = 0, right = 0 } } }`
-- @return the stylized string
local function stylize(str, opts)
	opts = util.default_tbl(opts, {
		padding = { left = 0, right = 0 },
		separator = { left = "", right = "" },
		show_empty = false,
		icon = { kind = "NONE", padding = { left = 0, right = 0 } },
	})
	local icon = util.pad_string(icons[opts.icon.kind], opts.icon.padding)
	return str
		and (str ~= "" or opts.show_empty)
		and opts.separator.left .. util.pad_string(icon .. str, opts.padding) .. opts.separator.right
		or ""
end

--- A provider function for displaying a single string
-- @param opts options passed to the stylize function
-- @return the stylized statusline string
-- @usage local heirline_component = { provider = astronvim.status.provider.str({ str = "Hello" }) }
function M.provider.str(opts)
	opts = util.default_tbl(opts, { str = " " })
	return stylize(opts.str, opts)
end

--- A provider function for the fill string
-- @return the statusline string for filling the empty space
-- @usage local heirline_component = { provider = astronvim.status.provider.fill }
function M.provider.fill() return "%=" end

--- A provider function for showing if spellcheck is on
-- @param opts options passed to the stylize function
-- @return the function for outputting if spell is enabled
-- @usage local heirline_component = { provider = astronvim.status.provider.spell() }
-- @see astronvim.status.utils.stylize
function M.provider.spell(opts)
	opts = util.default_tbl(opts, { str = "", icon = { kind = "Spellcheck" }, show_empty = true })
	return function() return stylize(vim.wo.spell and opts.str, opts) end
end

--- A provider function for showing if paste is enabled
-- @param opts options passed to the stylize function
-- @return the function for outputting if paste is enabled

-- @usage local heirline_component = { provider = astronvim.status.provider.paste() }
-- @see astronvim.status.utils.stylize
function M.provider.paste(opts)
	opts = util.default_tbl(opts, { str = "", icon = { kind = "Paste" }, show_empty = true })
	return function() return stylize(vim.opt.paste:get() and opts.str, opts) end
end

--- A provider function for displaying if a macro is currently being recorded
-- @param opts a prefix before the recording register and options passed to the stylize function
-- @return a function that returns a string of the current recording status
-- @usage local heirline_component = { provider = astronvim.status.provider.macro_recording() }
-- @see astronvim.status.utils.stylize
function M.provider.macro_recording(opts)
	opts = util.default_tbl(opts, { prefix = "@" })
	return function()
		local register = vim.fn.reg_recording()
		if register ~= "" then register = opts.prefix .. register end
		return stylize(register, opts)
	end
end

--- A provider function for displaying the current search count
-- @param opts options for `vim.fn.searchcount` and options passed to the stylize function
-- @return a function that returns a string of the current search location
-- @usage local heirline_component = { provider = astronvim.status.provider.search_count() }
-- @see astronvim.status.utils.stylize
function M.provider.search_count(opts)
	local search_func = vim.tbl_isempty(opts or {}) and function() return vim.fn.searchcount() end
		or function() return vim.fn.searchcount(opts) end
	return function()
		local search_ok, search = pcall(search_func)
		if search_ok and type(search) == "table" and search.total then
			return stylize(
				string.format(
					"%s%d/%s%d",
					search.current > search.maxcount and ">" or "",
					math.min(search.current, search.maxcount),
					search.incomplete == 2 and ">" or "",
					math.min(search.total, search.maxcount)
				),
				opts
			)
		end
	end
end

--- A provider function for showing the text of the current vim mode
-- @param opts options for padding the text and options passed to the stylize function
-- @return the function for displaying the text of the current vim mode
-- @usage local heirline_component = { provider = astronvim.status.provider.mode_text() }
-- @see astronvim.status.utils.stylize
function M.provider.mode_text(opts)
	local max_length =
	math.max(unpack(vim.tbl_map(function(str) return #str[1] end, vim.tbl_values(modes))))
	return function()
		local text = modes[vim.fn.mode()][1]
		if opts.pad_text then
			local padding = max_length - #text
			if opts.pad_text == "right" then
				text = string.rep(" ", padding) .. text
			elseif opts.pad_text == "left" then
				text = text .. string.rep(" ", padding)
			elseif opts.pad_text == "center" then
				text = string.rep(" ", math.floor(padding / 2))
					.. text
					.. string.rep(" ", math.ceil(padding / 2))
			end
		end
		return stylize(text, opts)
	end
end

--- A provider function for showing the percentage of the current location in a document
-- @param opts options for Top/Bot text, fixed width, and options passed to the stylize function
-- @return the statusline string for displaying the percentage of current document location
-- @usage local heirline_component = { provider = astronvim.status.provider.percentage() }
-- @see astronvim.status.utils.stylize
function M.provider.percentage(opts)
	opts = util.default_tbl(opts, { fixed_width = false, edge_text = true })
	return function()
		local text = "%" .. (opts.fixed_width and "3" or "") .. "p%%"
		if opts.edge_text then
			local current_line = vim.fn.line(".")
			if current_line == 1 then
				text = (opts.fixed_width and " " or "") .. "Top"
			elseif current_line == vim.fn.line("$") then
				text = (opts.fixed_width and " " or "") .. "Bot"
			end
		end
		return stylize(text, opts)
	end
end

--- A provider function for showing the current line and character in a document
-- @param opts options for padding the line and character locations and options passed to the stylize function
-- @return the statusline string for showing location in document line_num:char_num
-- @usage local heirline_component = { provider = astronvim.status.provider.ruler({ pad_ruler = { line = 3, char = 2 } }) }
-- @see astronvim.status.utils.stylize
function M.provider.ruler(opts)
	opts = util.default_tbl(opts, { pad_ruler = { line = 0, char = 0 } })
	return stylize(string.format("%%%dl:%%%dc", opts.pad_ruler.line, opts.pad_ruler.char), opts)
end

--- A provider function for showing the current location as a scrollbar
-- @param opts options passed to the stylize function
-- @return the function for outputting the scrollbar
-- @usage local heirline_component = { provider = astronvim.status.provider.scrollbar() }
-- @see astronvim.status.utils.stylize
function M.provider.scrollbar(opts)
	local sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }
	return function()
		local curr_line = vim.api.nvim_win_get_cursor(0)[1]
		local lines = vim.api.nvim_buf_line_count(0)
		local i = math.floor((curr_line - 1) / lines * #sbar) + 1
		return stylize(string.rep(sbar[i], 2), opts)
	end
end

--- A provider to simply show a cloes button icon
-- @param opts options passed to the stylize function and the kind of icon to use
-- @return return the stylized icon
-- @usage local heirline_component = { provider = astronvim.status.provider.close_button() }
-- @see astronvim.status.utils.stylize
function M.provider.close_button(opts)
	opts = util.default_tbl(opts, { kind = "BufferClose" })
	print("icon:" .. opts.kind .. ": " .. icons[opts.kind])
	return stylize(icons[opts.kind], opts)
end

--- A provider function for showing the current filetype
-- @param opts options passed to the stylize function
-- @return the function for outputting the filetype
-- @usage local heirline_component = { provider = astronvim.status.provider.filetype() }
-- @see astronvim.status.utils.stylize
function M.provider.filetype(opts)
	return function(self)
		local buffer = vim.bo[self and self.bufnr or 0]
		return stylize(string.lower(buffer.filetype), opts)
	end
end

--- A provider function for showing the current filename
-- @param opts options for argument to fnamemodify to format filename and options passed to the stylize function
-- @return the function for outputting the filename
-- @usage local heirline_component = { provider = astronvim.status.provider.filename() }
-- @see astronvim.status.utils.stylize
function M.provider.filename(opts)
	opts = util.default_tbl(opts, {
		fallback = "[No Name]",
		fname = function(nr) return vim.api.nvim_buf_get_name(nr) end,
		modify = ":t",
	})
	return function(self)
		local filename = vim.fn.fnamemodify(opts.fname(self and self.bufnr or 0), opts.modify)
		return stylize((filename == "" and opts.fallback or filename), opts)
	end
end

--- Get a unique filepath between all buffers
-- @param opts options for function to get the buffer name, a buffer number, max length, and options passed to the stylize function
-- @return path to file that uniquely identifies each buffer
-- @usage local heirline_component = { provider = astronvim.status.provider.unique_path() }
-- @see astronvim.status.utils.stylize
function M.provider.unique_path(opts)
	opts = util.default_tbl(opts, {
		buf_name = function(bufnr)
			return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
		end,
		bufnr = 0,
		max_length = 16,
	})
	return function(self)
		opts.bufnr = self and self.bufnr or opts.bufnr
		local name = opts.buf_name(opts.bufnr)
		local unique_path = ""
		-- check for same buffer names under different dirs
		for _, value in ipairs(tools.get_valid_buffers()) do
			if name == opts.buf_name(value) and value ~= opts.bufnr then
				local other = {}
				for match in (vim.api.nvim_buf_get_name(value) .. "/"):gmatch("(.-)" .. "/") do
					table.insert(other, match)
				end

				local current = {}
				for match in (vim.api.nvim_buf_get_name(opts.bufnr) .. "/"):gmatch("(.-)" .. "/") do
					table.insert(current, match)
				end

				unique_path = ""

				for i = #current - 1, 1, -1 do
					local value_current = current[i]
					local other_current = other[i]

					if value_current ~= other_current then
						unique_path = value_current .. "/"
						break
					end
				end
				break
			end
		end
		return stylize(
			(
			opts.max_length > 0
				and #unique_path > opts.max_length
				and string.sub(unique_path, 1, opts.max_length - 2) .. icons.Ellipsis .. "/"
			) or unique_path,
			opts
		)
	end
end

--- A provider function for showing if the current file is modifiable
-- @param opts options passed to the stylize function
-- @return the function for outputting the indicator if the file is modified
-- @usage local heirline_component = { provider = astronvim.status.provider.file_modified() }
-- @see astronvim.status.utils.stylize
function M.provider.file_modified(opts)
	opts = util.default_tbl(opts, { str = "", icon = { kind = "FileModified" }, show_empty = true })
	return function(self)
		return stylize(condition.file_modified((self or {}).bufnr) and opts.str, opts)
	end
end

--- A provider function for showing if the current file is read-only
-- @param opts options passed to the stylize function
-- @return the function for outputting the indicator if the file is read-only
-- @usage local heirline_component = { provider = astronvim.status.provider.file_read_only() }
-- @see astronvim.status.utils.stylize
function M.provider.file_read_only(opts)
	opts = util.default_tbl(opts, { str = "", icon = { kind = "FileReadOnly" }, show_empty = true })
	return function(self)
		return stylize(condition.file_read_only((self or {}).bufnr) and opts.str, opts)
	end
end

--- A provider function for showing the current filetype icon
-- @param opts options passed to the stylize function
-- @return the function for outputting the filetype icon
-- @usage local heirline_component = { provider = astronvim.status.provider.file_icon() }
-- @see astronvim.status.utils.stylize
function M.provider.file_icon(opts)
	return function(self)
		local devicons_avail, devicons = pcall(require, "nvim-web-devicons")
		if not devicons_avail then return "" end
		local ft_icon, _ = devicons.get_icon(
			vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self and self.bufnr or 0), ":t"),
			nil,
			{ default = true }
		)
		return stylize(ft_icon, opts)
	end
end

--- A provider function for showing the current git branch
-- @param opts options passed to the stylize function
-- @return the function for outputting the git branch
-- @usage local heirline_component = { provider = astronvim.status.provider.git_branch() }
-- @see astronvim.status.utils.stylize
function M.provider.git_branch(opts)
	return function(self) return stylize(vim.b[self and self.bufnr or 0].gitsigns_head or "", opts) end
end

--- A provider function for showing the current git diff count of a specific type
-- @param opts options for type of git diff and options passed to the stylize function
-- @return the function for outputting the git diff
-- @usage local heirline_component = { provider = astronvim.status.provider.git_diff({ type = "added" }) }
-- @see astronvim.status.utils.stylize
function M.provider.git_diff(opts)
	if not opts or not opts.type then return end
	return function(self)
		local status = vim.b[self and self.bufnr or 0].gitsigns_status_dict
		return stylize(
			status and status[opts.type] and status[opts.type] > 0 and tostring(status[opts.type])
			or "",
			opts
		)
	end
end

--- A provider function for showing the current diagnostic count of a specific severity
-- @param opts options for severity of diagnostic and options passed to the stylize function
-- @return the function for outputting the diagnostic count
-- @usage local heirline_component = { provider = astronvim.status.provider.diagnostics({ severity = "ERROR" }) }
-- @see astronvim.status.utils.stylize
function M.provider.diagnostics(opts)
	if not opts or not opts.severity then return end
	return function(self)
		local bufnr = self and self.bufnr or 0
		local count = #vim.diagnostic.get(
			bufnr,
			opts.severity and { severity = vim.diagnostic.severity[opts.severity] }
		)
		return stylize(count ~= 0 and tostring(count) or "", opts)
	end
end

--- A provider function for showing the current progress of loading language servers
-- @param opts options passed to the stylize function
-- @return the function for outputting the LSP progress
-- @usage local heirline_component = { provider = astronvim.status.provider.lsp_progress() }
-- @see astronvim.status.utils.stylize
function M.provider.lsp_progress(opts)
	return function()
		local Lsp = vim.lsp.util.get_progress_messages()[1]
		return stylize(
			Lsp
			and string.format(
				" %%<%s %s %s (%s%%%%) ",
				icons.get(
					"LSP"
					.. (
					(Lsp.percentage or 0) >= 70
						and { "Loaded", "Loaded", "Loaded" }
						or {
							"Loading1",
							"Loading2",
							"Loading3",
						}
					)[math.floor(vim.loop.hrtime() / 12e7) % 3 + 1]
				),
				Lsp.title or "",
				Lsp.message or "",
				Lsp.percentage or 0
			)
			or "",
			opts
		)
	end
end

--- A provider function for showing the connected LSP client names
-- @param opts options for explanding null_ls clients, max width percentage, and options passed to the stylize function
-- @return the function for outputting the LSP client names
-- @usage local heirline_component = { provider = astronvim.status.provider.lsp_client_names({ expand_null_ls = true, truncate = 0.25 }) }
-- @see astronvim.status.utils.stylize
function M.provider.lsp_client_names(opts)
	opts = util.default_tbl(opts, { expand_null_ls = true, truncate = 0.25 })
	return function(self)
		local buf_client_names = {}
		for _, client in pairs(vim.lsp.get_active_clients({ bufnr = self and self.bufnr or 0 })) do
			if client.name == "null-ls" and opts.expand_null_ls then
				local null_ls_sources = {}
				for _, type in ipairs({ "FORMATTING", "DIAGNOSTICS" }) do
					for _, source in ipairs(require("util.null_ls").sources(vim.bo.filetype, type)) do
						null_ls_sources[source] = true
					end
				end
				vim.list_extend(buf_client_names, vim.tbl_keys(null_ls_sources))
			else
				table.insert(buf_client_names, client.name)
			end
		end
		local str = table.concat(buf_client_names, ", ")
		if type(opts.truncate) == "number" then
			local max_width = math.floor(tools.width() * opts.truncate)
			if #str > max_width then str = string.sub(str, 0, max_width) .. "…" end
		end
		return stylize(str, opts)
	end
end

return M
