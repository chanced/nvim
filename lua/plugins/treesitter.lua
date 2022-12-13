local function config_treesitter()
	require("nvim-treesitter.configs").setup({
		ensure_installed = {
			"bash",
			"comment",
			"css",
			"diff",
			"dot",
			"dockerfile",
			"fish",
			"git_rebase",
			"gitattributes",
			"gitcommit",
			"gitignore",
			"go",
			"gomod",
			"gowork",
			"hcl",
			"help",
			"html",
			"http",
			"javascript",
			"jq",
			"jsdoc",
			"json",
			"lua",
			"make",
			"markdown",
			"markdown_inline",
			"proto",
			"python",
			"regex",
			"ruby",
			"rust",
			"scss",
			"sql",
			"svelte",
			"toml",
			"tsx",
			"typescript",
			"vim",
			"vhs",
			"vue",
			"yaml",
		},
		highlight = {
			enable = true,
		},
		rainbow = {
			enable = true,
			extended_mode = true,
			max_file_lines = nil,
		},
	})
end

return function(use)
	-- syntax tree parsing for more intelligent syntax highlighting and code navigation
	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
		config = config_treesitter,
	})
	use({
		"p00f/nvim-ts-rainbow",
		after = "nvim-treesitter",
	})

	use({
		"nvim-treesitter/nvim-treesitter-textobjects",
		requires = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-treesitter.configs").setup({
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "gnn", -- start treesitter selection process
						scope_incremental = "gnm", -- increment selection to surrounding scope
						node_incremental = ";", -- increment selection to next 'node'
						node_decremental = ",", -- decrement selection to prev 'node'
					},
				},
				indent = {
					enable = true,
				},
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						include_surrounding_whitespace = false,
						keymaps = {
							["af"] = {
								query = "@function.outer",
								desc = "select around a function",
							},
							["if"] = {
								query = "@function.inner",
								desc = "select inner part of a function",
							},
							["ac"] = { query = "@class.outer", desc = "select around a class" },
							["ic"] = {
								query = "@class.inner",
								desc = "select inner part of a class",
							},
						},
						selection_modes = {
							["@parameter.outer"] = "v",
							["@function.outer"] = "V",
							["@class.outer"] = "<c-v>",
						},
					},
					move = {
						enable = true,
						set_jumps = true,
						goto_next_start = {
							["]]"] = "@function.outer",
							["]s"] = "@class.outer",
							["]c"] = "@class.outer",
						},
						goto_previous_start = {
							["[f"] = "@function.outer",
							["[s"] = "@class.outer",
							["[c"] = "@class.outer",
						},
					},
				},
			})
		end,
	})

	-- Highlight Arguments
	use({
		"m-demare/hlargs.nvim", -- https://github.com/m-demare/hlargs.nvim
		requires = { "nvim-treesitter/nvim-treesitter" },
		config = function() require("hlargs").setup() end,
	})

	use({
		"nvim-treesitter/nvim-treesitter-context",
		requires = "nvim-treesitter/nvim-treesitter",
		config = function()
			require("treesitter-context").setup({
				separator = "-",
			})
		end,
	})
	use({
		"RRethy/nvim-treesitter-endwise",
		config = function()
			require("nvim-treesitter.configs").setup({
				endwise = {
					enable = true,
				},
			})
		end,
	})
	use({
		"windwp/nvim-ts-autotag",
		config = function() require("nvim-ts-autotag").setup({}) end,
	})
end
