local modes = require("plugins.heirline.modes")
local M = {}

--- Get the highlight background color of the lualine theme for the current colorscheme
-- @param  mode the neovim mode to get the color of
-- @param  fallback the color to fallback on if a lualine theme is not present
-- @return The background color of the lualine theme or the fallback parameter if one doesn't exist
function M.lualine_mode(mode, fallback)
	local lualine_avail, lualine =
	pcall(require, "lualine.themes." .. (vim.g.colors_name or "default_theme"))
	local lualine_opts = lualine_avail and lualine[mode]
	return lualine_opts and type(lualine_opts.a) == "table" and lualine_opts.a.bg or fallback
end

--- Get the highlight for the current mode
-- @return the highlight group for the current mode
-- @usage local heirline_component = { provider = "Example Provider", hl = astronvim.status.hl.mode },
function M.mode() return { bg = M.mode_bg() } end

--- Get the foreground color group for the current mode, good for usage with Heirline surround utility
-- @return the highlight group for the current mode foreground
-- @usage local heirline_component = require("heirline.utils").surround({ "|", "|" }, astronvim.status.hl.mode_bg, heirline_component),

function M.mode_bg() return modes[vim.fn.mode()][2] end

--- Get the foreground color group for the current filetype
-- @return the highlight group for the current filetype foreground
-- @usage local heirline_component = { provider = astronvim.status.provider.fileicon(), hl = astronvim.status.hl.filetype_color },
function M.filetype_color(self)
	local devicons_avail, devicons = pcall(require, "nvim-web-devicons")
	if not devicons_avail then return {} end
	local _, color = devicons.get_icon_color(
		vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self and self.bufnr or 0), ":t"),
		nil,
		{ default = true }
	)
	return { fg = color }
end

return M
