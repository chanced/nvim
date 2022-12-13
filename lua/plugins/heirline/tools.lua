local M = {}
local util = require("util")
local seperators = require("plugins.heirline.seperators")

--- A utility function to get the width of the bar
-- @param is_winbar boolean true if you want the width of the winbar, false if you want the statusline width
-- @return the width of the specified bar
function M.width(is_winbar)
	return vim.o.laststatus == 3 and not is_winbar and vim.o.columns
		or vim.api.nvim_win_get_width(0)
end

--- Surround component with separator and color adjustment
-- @param separator the separator index to use in `seperators`
-- @param color the color to use as the separator foreground/component background
-- @param component the component to surround
-- @param condition the condition for displaying the surrounded component
-- @return the new surrounded component
function M.surround(separator, color, component, condition)
	local function surround_color(self)
		local colors = type(color) == "function" and color(self) or color
		return type(colors) == "string" and { main = colors } or colors
	end

	separator = type(separator) == "string" and seperators[separator] or separator
	local surrounded = { condition = condition }
	if separator[1] ~= "" then
		table.insert(surrounded, {
			provider = separator[1],
			hl = function(self)
				local s_color = surround_color(self)
				if s_color then return { fg = s_color.main, bg = s_color.left } end
			end,
		})
	end
	table.insert(surrounded, {
		hl = function(self)
			local s_color = surround_color(self)
			if s_color then return { bg = s_color.main } end
		end,
		util.default_tbl({}, component),
	})
	if separator[2] ~= "" then
		table.insert(surrounded, {
			provider = separator[2],
			hl = function(self)
				local s_color = surround_color(self)
				if s_color then return { fg = s_color.main, bg = s_color.right } end
			end,
		})
	end
	return surrounded
end

--- Check if a buffer is valid
-- @param bufnr the buffer to check
-- @return true if the buffer is valid or false
function M.is_valid_buffer(bufnr)
	if not bufnr or bufnr < 1 then return false end
	return vim.bo[bufnr].buflisted and vim.api.nvim_buf_is_valid(bufnr)
end

--- Get all valid buffers
-- @return array-like table of valid buffer numbers
function M.get_valid_buffers() return vim.tbl_filter(M.is_valid_buffer, vim.api.nvim_list_bufs()) end

--- Encode a position to a single value that can be decoded later
-- @param line line number of position
-- @param col column number of position
-- @param winnr a window number
-- @return the encoded position
function M.encode_pos(line, col, winnr)
	return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr)
end

--- Decode a previously encoded position to it's sub parts
-- @param c the encoded position
-- @return line number, column number, window id
function M.decode_pos(c) return bit.rshift(c, 16), bit.band(bit.rshift(c, 6), 1023), bit.band(c, 63) end

--- An `init` function to build a set of children components for LSP breadcrumbs
-- @param opts options for configuring the breadcrumbs (default: `{ separator = " > ", icon = { enabled = true, hl = false }, padding = { left = 0, right = 0 } }`)
-- @return The Heirline init function
-- @usage local heirline_component = { init = astronvim.status.init.breadcrumbs { padding = { left = 1 } } }
function M.breadcrumbs(opts)
	opts = util.default_tbl(opts, {
		separator = " > ",
		icon = { enabled = true, hl = false },
		padding = { left = 0, right = 0 },
	})
	return function(self)
		local data = require("aerial").get_location(true) or {}
		local children = {}
		-- create a child for each level
		for i, d in ipairs(data) do
			local pos = M.encode_pos(d.lnum, d.col, self.winnr)
			local child = {
				{ provider = string.gsub(d.name, "%%", "%%%%"):gsub("%s*->%s*", "") }, -- add symbol name
				on_click = { -- add on click function
					minwid = pos,
					callback = function(_, minwid)
						local lnum, col, winnr = M.decode_pos(minwid)
						vim.api.nvim_win_set_cursor(vim.fn.win_getid(winnr), { lnum, col })
					end,
					name = "heirline_breadcrumbs",
				},
			}
			if opts.icon.enabled then -- add icon and highlight if enabled
				table.insert(child, 1, {
					provider = string.format("%s ", d.icon),
					hl = opts.icon.hl and string.format("Aerial%sIcon", d.kind) or nil,
				})
			end
			if #data > 1 and i < #data then table.insert(child, { provider = opts.separator }) end -- add a separator only if needed
			table.insert(children, child)
		end
		if opts.padding.left > 0 then -- add left padding
			table.insert(
				children,
				1,
				{ provider = util.pad_string(" ", { left = opts.padding.left - 1 }) }
			)
		end
		if opts.padding.right > 0 then -- add right padding
			table.insert(
				children,
				{ provider = util.pad_string(" ", { right = opts.padding.right - 1 }) }
			)
		end
		-- instantiate the new child
		self[1] = self:new(children, 1)
	end
end

--- An `init` function to build multiple update events which is not supported yet by Heirline's update field
-- @param opts an array like table of autocmd events as either just a string or a table with custom patterns and callbacks.
-- @return The Heirline init function
-- @usage local heirline_component = { init = astronvim.status.init.update_events { "BufEnter", { "User", pattern = "LspProgressUpdate" } } }
function M.update_events(opts)
	return function(self)
		if not rawget(self, "once") then
			local clear_cache = function() self._win_cache = nil end
			for _, event in ipairs(opts) do
				local event_opts = { callback = clear_cache }
				if type(event) == "table" then
					event_opts.pattern = event.pattern
					event_opts.callback = event.callback or clear_cache
					event.pattern = nil
					event.callback = nil
				end
				vim.api.nvim_create_autocmd(event, event_opts)
			end
			self.once = true
		end
	end
end

return M
