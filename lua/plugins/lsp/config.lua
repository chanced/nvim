local lspconfig = require("lspconfig")
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local function set_keymaps(keymaps)
	for mode, mode_keymaps in pairs(keymaps) do
		for key, params in pairs(mode_keymaps) do
			local cmd = params[1]
			local opts = params[2] or {}
			vim.keymap.set(mode, key, cmd, opts)
		end
	end
end

-- LSP settings (for overriding per client)
local handlers = {
	-- ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
	-- ["textDocument/signatureHelp"] = vim.lsp.with(
	--		vim.lsp.handlers.signature_help,
	--		{ border = "rounded" }
	--	),
}

local function default_keymap(bufnr)
	local opts =
	function(desc) return { noremap = true, silent = true, buffer = bufnr, desc = desc } end
	return {
		n = {

			["©+."] = { vim.lsp.buf.code_action, opts("code action") },
			["gD"] = { vim.lsp.buf.declaration, opts("Go to declaration") },
			["gd"] = { vim.lsp.buf.definition, opts("Go to definition") },
			["gi"] = { vim.lsp.buf.implementation, opts("Go to implementation") },
			["gt"] = { vim.lsp.buf.type_definition, opts("go to type definition") },
			["K"] = { vim.lsp.buf.hover, opts("Hover") },
			["<C-.>"] = { vim.lsp.buf.code_action, opts("Code action") },
			["[d"] = { vim.diagnostic.goto_prev, opts("Go to previous diagnostic") },
			["]d"] = { vim.diagnostic.goto_next, opts("Go to next diagnostic") },
			["<leader>rn"] = { vim.lsp.buf.rename, opts("Rename") },
			["<leader>ca"] = { vim.lsp.buf.code_action, opts("Code action") },
			["gr"] = { "<cmd>Telescope lsp_references<cr>", opts("References") },
			["<F2>"] = {
				vim.lsp.buf.rename,
				opts("Rename symbol"),
			},
			["<leader>rr"] = { "<cmd>RustRunnables<cr>", opts("rust runnables") },
		},
	}
end

local formatting = function(client)
	if client.supports_method("textDocument/formatting") then
		vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = augroup,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format({
					filter = function(c) return true end,
					bufnr = bufnr,
				})
			end,
		})
	end
end

local default_on_attach = function(client, bufnr)
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
	vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")
	vim.api.nvim_buf_set_option(bufnr, "tagfunc", "v:lua.vim.lsp.tagfunc")
	require("illuminate").on_attach(client)
	set_keymaps(default_keymap(bufnr))
	vim.opt.signcolumn = "yes"
	formatting(client)
end

local function setup_rust(capabilities)
	--Setup rust_analyzer via rust - tools.nvim
	-- lspconfig["rust_analzyer"].setup({
	-- 	on_attach = default_on_attach,
	-- 	capabilities = capabilities,
	-- })
	local on_attach = function(client, bufnr)
		local opts =
		function(desc) return { noremap = true, silent = true, buffer = bufnr, desc = desc } end
		local rt = require("rust-tools")
		vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
		vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")
		vim.api.nvim_buf_set_option(bufnr, "tagfunc", "v:lua.vim.lsp.tagfunc")
		require("illuminate").on_attach(client)
		-- Set updatetime for CursorHold
		-- 300ms of no cursor movement to trigger CursorHold
		vim.opt.updatetime = 100
		-- Show diagnostic popup on cursor hover
		local diag_float_grp = vim.api.nvim_create_augroup("DiagnosticFloat", { clear = true })
		vim.api.nvim_create_autocmd("CursorHold", {
			callback = function() vim.diagnostic.open_float(nil, { focusable = false }) end,
			group = diag_float_grp,
		})
		local keymap = vim.tbl_deep_extend("force", default_keymap(), {
			n = {},
		})
		set_keymaps(keymap)
		vim.opt.signcolumn = "yes"
		formatting(client)
	end

	require("rust-tools").setup({
		tools = {

			autoSetHints = true,
			inlay_hints = {
				auto = false,
				show_parameter_hints = true,
				--	parameter_hints_prefix = "<- ",
				--	other_hints_prefix = "=> ",
			},
			runnables = {
				use_telescope = true,
			},
		},
		server = {
			capabilities = capabilities,
			on_attach = on_attach,
			checkOnSave = {
				allFeatures = true,
				overrideCommand = {
					"cargo",
					"clippy",
					"--message-format=json",
					"--workspace",
					"--all-targets",
					"--all-features",
				},
			},
		},
	})
end

local lsp_list = {
	--rust_analyzer = setup_rust,
	sumneko_lua = {
		settings = {
			Lua = {
				runtime = {
					--Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
					version = "LuaJIT",
				},
				diagnostics = {
					--Get the language server to recognize the `vim` global
					globals = { "vim", "bit" },
				},
				workspace = {
					--Make the server aware of Neovim runtime files
					library = vim.api.nvim_get_runtime_file("", true),
				},
				--Do not send telemetry data containing a randomized but unique identifier
				telemetry = {
					enable = false,
				},
			},
		},
	},
	rome = function() end,
	-- eslint = {
	-- 	filetypes = { "json" },
	-- },
	-- tsserver = {
	-- 	filetypes = { "ts" },
	-- },
}

return function(server_name, capabilities)
	vim.lsp.set_log_level("trace")
	local cfg = {}
	local server_cfg = lsp_list[server_name]
	if server_cfg ~= nil then
		if type(server_cfg) == "function" then
			return server_cfg(capabilities)
		else
			cfg = server_cfg
		end
	end
	cfg = vim.tbl_extend("force", cfg, {
		capabilities = capabilities,
		on_attach = default_on_attach,
		handlers = handlers,
	})
	lspconfig[server_name].setup(cfg)
end
