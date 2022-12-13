local function config_mason()
	local mason = require("mason")
	local mason_lsp_cfg = require("mason-lspconfig")
	mason.setup({
		ui = {
			icons = {
				package_installed = "✓",
				package_pending = "➜",
				package_uninstalled = "✗",
			},
		},
	})
	mason_lsp_cfg.setup({
		ensure_installed = {
			"rust_analyzer",
			"golangci_lint_ls",
			"gopls",
			"cssls",
			"dockerls",
			"eslint",
			"emmet_ls",
			"dotls",
			"rome",
			"html",
			"sqlls",
			"jsonls",
			"yamlls",
			"vimls",
			"svelte",
			"tsserver",
			"tailwindcss",
			"sumneko_lua",
		},
	})
end

-- Keymaps for Luasnip
local function config_lsp()
	local lspconfig = require("lspconfig")
	local mason_lsp_cfg = require("mason-lspconfig")
	local cmp_nvim_lsp = require("cmp_nvim_lsp")
	local capabilities = cmp_nvim_lsp.default_capabilities()
	local installed = mason_lsp_cfg.get_installed_servers()
	local config_lsp_impl = require("plugins.lsp.config")
	for _, server in ipairs(installed) do
		config_lsp_impl(server, capabilities)
	end
end

return function(use)
	use({
		"simrat39/rust-tools.nvim",
	})
	use({
		"williamboman/mason.nvim",
		config = config_mason,
		requires = { "williamboman/mason-lspconfig.nvim" },
	})
	use({
		"neovim/nvim-lspconfig",
		config = config_lsp,
		after = { "cmp-nvim-lsp", "mason.nvim", "rust-tools.nvim", "null-ls.nvim" },
	})
	use({
		"folke/lsp-colors.nvim", -- https://github.com/folke/lsp-colors.nvim
		config = function() require("lsp-colors").setup() end,
	})
	-- use({
	-- 	"j-hui/fidget.nvim", -- https://github.com/j-hui/fidget.nvim
	-- 	config = function() require("fidget").setup({}) end,
	-- })
end
