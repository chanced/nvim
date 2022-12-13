local util = require("util")
local component = require("plugins.heirline.component").component
local condition = require("plugins.heirline.condition")
local heirline = require("heirline")

-- setup mostly lifted from astronvim

local function setup_colors()
	local lualine_mode = function(mode, fallback)
		local lualine_avail, lualine =
		pcall(require, "lualine.themes." .. (vim.g.colors_name or "default_theme"))
		local lualine_opts = lualine_avail and lualine[mode]
		return lualine_opts and type(lualine_opts.a) == "table" and lualine_opts.a.bg or fallback
	end

	local StatusLine = util.get_hl_group("StatusLine")
	local WinBar = util.get_hl_group("WinBar")
	local WinBarNC = util.get_hl_group("WinBarNC")
	local Conditional = util.get_hl_group("Conditional")
	local String = util.get_hl_group("String")
	local TypeDef = util.get_hl_group("TypeDef")
	local GitSignsAdd = util.get_hl_group("GitSignsAdd", { fg = "#76946A" })
	local GitSignsChange = util.get_hl_group("GitSignsChange", { fg = "#DCA561" })
	local GitSignsDelete = util.get_hl_group("GitSignsDelete", { fg = "#C34043" })
	local DiagnosticError = util.get_hl_group("DiagnosticError", { fg = "#E82424" })
	local DiagnosticWarn = util.get_hl_group("DiagnosticWarn", { fg = "#FF9E3B" })
	local DiagnosticInfo = util.get_hl_group("DiagnosticInfo", { fg = "#658594" })
	local DiagnosticHint = util.get_hl_group("DiagnosticHint", "#6A9589")
	local HeirlineInactive = util.get_hl_group("HeirlineInactive", { fg = nil }).fg
		or lualine_mode("inactive", util.get_hl_group("Commnet", { fg = nil }))
	local HeirlineNormal = util.get_hl_group("HeirlineNormal", { fg = nil }).fg
		or lualine_mode("normal")
	local HeirlineInsert = util.get_hl_group("HeirlineInsert", { fg = nil }).fg
		or lualine_mode("insert")
	local HeirlineVisual = util.get_hl_group("HeirlineVisual", { fg = nil }).fg
		or lualine_mode("visual")
	local HeirlineReplace = util.get_hl_group("HeirlineReplace", { fg = nil }).fg
		or lualine_mode("replace")
	local HeirlineCommand = util.get_hl_group("HeirlineCommand", { fg = nil }).fg
		or lualine_mode("command")
	local HeirlineTerminal = util.get_hl_group("HeirlineTerminal", { fg = nil }).fg
		or lualine_mode("inactive", HeirlineInsert)

	--added = colorks.autumnGreen,
	-- removed = colors.autumnRed,
	-- changed = colors.autumnYellow,
	-- error = colors.samuraiRed,
	-- warning = colors.roninYellow,
	-- info = colors.dragonBlue,
	-- hint = colors.waveAqua1,
	local colors = {
		fg = StatusLine.fg,
		bg = StatusLine.bg,
		section_fg = StatusLine.fg,
		section_bg = StatusLine.bg,
		git_branch_fg = Conditional.fg,
		treesitter_fg = String.fg,
		scrollbar = TypeDef.fg,
		git_added = GitSignsAdd.fg,
		git_changed = GitSignsChange.fg,
		git_removed = GitSignsDelete.fg,
		diag_ERROR = DiagnosticError.fg,
		diag_WARN = DiagnosticWarn.fg,
		diag_INFO = DiagnosticInfo.fg,
		diag_HINT = DiagnosticHint.fg,
		winbar_fg = WinBar.fg,
		winbar_bg = WinBar.bg,
		winbarnc_fg = WinBarNC.fg,
		winbarnc_bg = WinBarNC.bg,
		inactive = HeirlineInactive,
		normal = HeirlineNormal,
		insert = HeirlineInsert,
		visual = HeirlineVisual,
		replace = HeirlineReplace,
		command = HeirlineCommand,
		terminal = HeirlineTerminal,
	}
	for _, section in ipairs({
		"git_branch",
		"file_info",
		"git_diff",
		"diagnostics",
		"lsp",
		"macro_recording",
		"cmd_info",
		"treesitter",
		"nav",
	}) do
		if not colors[section .. "_bg"] then colors[section .. "_bg"] = colors["section_bg"] end
		if not colors[section .. "_fg"] then colors[section .. "_fg"] = colors["section_fg"] end
	end
	return colors
end

heirline.load_colors(setup_colors())
local heirline_opts = {
	{
		hl = { fg = "fg", bg = "bg" },
		component.mode(),
		component.git_branch(),
		component.file_info({ filetype = {}, filename = false, file_modified = false } or nil),
		component.git_diff(),
		component.diagnostics(),
		component.fill(),
		component.cmd_info(),
		component.fill(),
		component.lsp(),
		component.treesitter(),
		component.nav(),
		component.mode({ surround = { separator = "right" } }),
	},
	{
		fallthrough = false,
		component.file_info({
			condition = function() return not condition.is_active() end,
			unique_path = {},
			file_icon = { hl = false },
			hl = { fg = "winbarnc_fg", bg = "winbarnc_bg" },
			surround = false,
			update = "BufEnter",
		}),
		component.breadcrumbs({ hl = { fg = "winbar_fg", bg = "winbar_bg" } }),
	},
}
heirline.setup(heirline_opts[1], heirline_opts[2], heirline_opts[3])

local augroup = vim.api.nvim_create_augroup("Heirline", { clear = true })
vim.api.nvim_create_autocmd("User", {
	pattern = "AstroColorScheme",
	group = augroup,
	desc = "Refresh heirline colors",
	callback = function() require("heirline.utils").on_colorscheme(setup_colors()) end,
})
vim.api.nvim_create_autocmd("User", {
	pattern = "HeirlineInitWinbar",
	group = augroup,
	desc = "Disable winbar for some filetypes",
	callback = function()
		if condition.buffer_matches({
			buftype = { "terminal", "prompt", "nofile", "help", "quickfix" },
			filetype = { "NvimTree", "neo-tree", "dashboard", "Outline", "aerial" },
		})
		then
			vim.opt_local.winbar = nil
		end
	end,
})
