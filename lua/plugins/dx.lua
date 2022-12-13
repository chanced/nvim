-- mason-null-ls.nvim
-- cmp-fish
-- cmp-nvim-lsp-document-symbol
-- cmp-nvim-lsp-signature-help
local function config_lspkind()
	require("lspkind").init({
		-- defines how annotations are shown
		-- default: symbol
		-- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
		mode = "text_symbol",

		-- default symbol map
		-- can be either 'default' (requires nerd-fonts font) or
		-- 'codicons' for codicon preset (requires vscode-codicons font)
		--
		-- default: 'default'
		preset = "default",

		-- override preset symbols
		--
		-- default: {}
		symbol_map = {
			Text = "",
			Method = "",
			Function = "",
			Constructor = "",
			Field = "ﰠ",
			Variable = "",
			Class = "ﴯ",
			Interface = "",
			Module = "",
			Property = "ﰠ",
			Unit = "塞",
			Value = "",
			Enum = "",
			Keyword = "",
			Snippet = "",
			Color = "",
			File = "",
			Reference = "",
			Folder = "",
			EnumMember = "",
			Constant = "",
			Struct = "פּ",
			Event = "",
			Operator = "",
			TypeParameter = "",
		},
	})
end

local function config_luasnip()
	local luasnip = require("luasnip")
	local types = require("luasnip.util.types")
	local from_vscode = require("luasnip/loaders/from_vscode")
	from_vscode.lazy_load()

	luasnip.setup({
		history = true,
		updateevents = "TextChanged,TextChangedI",
		enable_autosnippets = true,
		ext_opts = {
			[types.choiceNode] = {
				active = {
					virt_text = { { "<-" } },
				},
			},
		},
	})

	vim.keymap.set({ "i", "s" }, "<C-l>", function()
		if luasnip.jumpable(1) then luasnip.jump(1) end
	end, { silent = true })

	vim.keymap.set({ "i", "s" }, "<C-h>", function()
		if luasnip.jumpable(-1) then luasnip.jump(-1) end
	end, { silent = true })

	vim.keymap.set("i", "<C-e>", function()
		if luasnip.choice_active() then luasnip.change_choice(1) end
	end)

	require("snippets")
end

local function config_cmp()
	local luasnip = require("luasnip")
	local lspkind = require("lspkind")
	local cmp = require("cmp")
	local mapping = cmp.mapping.preset.insert({
		["<C-k>"] = cmp.mapping.select_prev_item(),
		["<C-j>"] = cmp.mapping.select_next_item(),
		["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
		["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
		["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
		["<C-S-J>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
		["<C-S-K>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
		["<C-e>"] = cmp.mapping({
			i = cmp.mapping.abort(),
			c = cmp.mapping.close(),
		}),
		-- Accept currently selected item. If none selected, `select` first item.
		-- Set `select` to `false` to only confirm explicitly selected items.
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	})
	cmp.setup({
		experimental = {
			ghost_text = true,
		},
		snippet = {
			expand = function(args) luasnip.lsp_expand(args.body) end,
		},
		mapping = mapping,
		sources = cmp.config.sources({
			{ name = "nvim_lsp_signature_help", priority = 1000 },
			{ name = "nvim_lsp", priority = 1000 },
			{ name = "nvim_lua", priority = 500 },
			{ name = "luasnip", priority = 300 },
			{ name = "path", priority = 200 },
			{ name = "buffer", keyword_length = 3, priority = 100 },
		}),
		formatting = {
			format = lspkind.cmp_format({
				mode = "symbol_text", -- show only symbol annotations
				maxwidth = 100, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
				ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
				-- The function below will be called before any actual modifications from lspkind
				-- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
				before = function(_, vim_item) return vim_item end,
			}),
		},
		window = {
			documentation = cmp.config.window.bordered(),
		},
	})

	--cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

	--cmp.setup.cmdline("/", {
	--	mapping = cmp.mapping.preset.cmdline(),
	--	sources = cmp.config.sources({
	--		{ name = "nvim_lsp_document_symbol" },
	--	}, {
	--		{ name = "buffer" },
	--	}),
	--})
	--cmp.setup.cmdline(":", {
	--	mapping = cmp.mapping.preset.cmdline(),
	--	sources = cmp.config.sources({
	--		{ name = "fish" },
	--	}, {
	--		{ name = "buffer" },
	--	}),
	--})
end

local function config_indent_blankline()
	vim.opt.listchars:append("eol:↴")
	require("indent_blankline").setup({
		space_char_blankline = " ",
		show_current_context = true,
		show_current_context_start = true,
	})
end

local function config_null_ls()
	local null_ls = require("null-ls")
	local mason_null_ls = require("mason-null-ls")
	mason_null_ls.setup({
		ensure_installed = {
			"hadolint",
			"rome",
			"prettierd",
			"golangci_lint",
			"goimports",
			"stylua",
			"shellcheck",
			"yamlfmt",
		},
		automatic_installation = true,
		automatic_setup = true, -- Recommended, but optional
	})
	local formatting = null_ls.builtins.formatting
	null_ls.setup({
		sources = {
			formatting.stylua,
			formatting.yamlfmt,
			formatting.rustfmt,
		},
	})
end

return function(use)
	use("RRethy/vim-illuminate")
	use({ "onsails/lspkind.nvim", config = config_lspkind })

	use({
		"L3MON4D3/LuaSnip",
		requires = { "rafamadriz/friendly-snippets" },
		config = config_luasnip,
	})
	use({
		"jose-elias-alvarez/null-ls.nvim",
		requires = {
			"jay-babu/mason-null-ls.nvim",
			"williamboman/mason.nvim",
		},
		config = config_null_ls,
	})
	use({
		"hrsh7th/nvim-cmp",
		requires = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-nvim-lsp-signature-help",
			"hrsh7th/cmp-nvim-lsp-document-symbol",
			"saadparwaiz1/cmp_luasnip",
			"mtoohey31/cmp-fish",
			"neovim/nvim-lspconfig",
		},
		after = { "LuaSnip", "lspkind.nvim" },
		config = config_cmp,
	})
	use("github/copilot.vim")
	use({
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup({
				disable_filetype = { "TelescopePrompt", "vim" },
			})
		end,
	})

	use({ "lukas-reineke/indent-blankline.nvim", config = config_indent_blankline })
	use({
		"zakharykaplan/nvim-retrail",
		config = function()
			require("retrail").setup({
				filetype = {
					exclude = {
						"",
						"checkhealth",
						"diff",
						"help",
						"lspinfo",
						"man",
						"mason",
						"TelescopePrompt",
						"Trouble",
						"WhichKey",
						"neo-tree",
					},
				},
			})
		end,
	})
end
