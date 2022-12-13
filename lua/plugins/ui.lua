local fzf_run = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && \
		cmake --build build --config Release && \
		cmake --install build --prefix build"

local function config_smart_splits()
	require("smart-splits").setup({
		-- Ignored filetypes (only while resizing)
		ignored_filetypes = {
			"nofile",
			"quickfix",
			"prompt",
		},
		-- Ignored buffer types (only while resizing)
		ignored_buftypes = { "NvimTree" },
		-- the default number of lines/columns to resize by at a time
		default_amount = 3,
		-- whether to wrap to opposite side when cursor is at an edge
		-- e.g. by default, moving left at the left edge will jump
		-- to the rightmost window, and vice versa, same for up/down.
		wrap_at_edge = true,
		-- when moving cursor between splits left or right,
		-- place the cursor on the same row of the *screen*
		-- regardless of line numbers. False by default.
		-- Can be overridden via function parameter, see Usage.
		move_cursor_same_row = false,
		-- resize mode options
		resize_mode = {
			-- key to exit persistent resize mode
			quit_key = "<ESC>",
			-- keys to use for moving in resize mode
			-- in order of left, down, up' right
			resize_keys = { "h", "j", "k", "l" },
			-- set to true to silence the notifications
			-- when entering/exiting persistent resize mode
			silent = false,
			-- must be functions, they will be executed when
			-- entering or exiting the resize mode
			hooks = {
				on_enter = nil,
				on_leave = nil,
			},
		},
		-- ignore these autocmd events (via :h eventignore) while processing
		-- smart-splits.nvim computations, which involve visiting different
		-- buffers and windows. These events will be ignored during processing,
		-- and un-ignored on completed. This only applies to resize events,
		-- not cursor movement events.
		ignored_events = {
			"BufEnter",
			"WinEnter",
		},
		-- enable or disable the tmux integration
		tmux_integration = true,
	})
end

local function trash(state)
	local tree = state.tree
	local node = tree:get_node()
	if node.type == "message" then return end
	local inputs = require("neo-tree.ui.inputs")
	local utils = require("neo-tree.utils")
	local manager = require("neo-tree.sources.manager")
	local refresh = utils.wrap(manager.refresh, "buffers")
	local _, name = utils.split_path(node.path)
	local msg = string.format("Are you sure you wish to delete '%s'?", name)
	inputs.confirm(msg, function(confirmed)
		if not confirmed then return end
		vim.api.nvim_command("silent !trash -F " .. node.path)
		refresh(state)
	end)
end

-- Trash the selections (visual mode)
-- local function trash_visual(state, selected_nodes)
-- 	local inputs = require("neo-tree.ui.inputs")
-- 	local cmds = require("neo-tree.sources.filesystem.commands")
-- 	local paths_to_trash = {}
-- 	for _, node in ipairs(selected_nodes) do
-- 		if node.type ~= "message" then table.insert(paths_to_trash, node.path) end
-- 	end
-- 	local msg = "Are you sure you wish to delete " .. #paths_to_trash .. " items?"
--
-- 	inputs.confirm(msg, function(confirmed)
-- 		if not confirmed then return end
-- 		for _, path in ipairs(paths_to_trash) do
-- 			vim.api.nvim_command("silent !trash -F " .. path)
-- 		end
-- 		cmds.refresh(state)
-- 	end)
-- end

local function config_neo_tree()
	-- todo: add rename event for ts and rust using the :match("^.+%.(.+)%/")
	-- see:	https://github.com/nvim-neo-tree/neo-tree.nvim/issues/308#issuecomment-1304765940z
	local neotree = require("neo-tree")

	vim.fn.sign_define("diagnosticsignerror", { text = " ", texthl = "diagnosticsignerror" })
	vim.fn.sign_define("diagnosticsignwarn", { text = " ", texthl = "diagnosticsignwarn" })
	vim.fn.sign_define("diagnosticsigninfo", { text = " ", texthl = "diagnosticsigninfo" })
	vim.fn.sign_define("diagnosticsignhint", { text = "", texthl = "diagnosticsignhint" })

	neotree.setup({
		close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
		popup_border_style = "rounded",
		enable_git_status = true,
		enable_diagnostics = true,
		sort_case_insensitive = false, -- used when sorting files and directories in the tree
		sort_function = nil, -- use a custom function for sorting files and directories in the tree
		default_component_configs = {
			container = {
				enable_character_fade = true,
			},
			indent = {
				indent_size = 2,
				padding = 1, -- extra padding on left hand side
				-- indent guides
				with_markers = true,
				indent_marker = "│",
				last_indent_marker = "└",
				highlight = "NeoTreeIndentMarker",
				-- expander config, needed for nesting files
				with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
				expander_collapsed = "",
				expander_expanded = "",
				expander_highlight = "NeoTreeExpander",
			},
			icon = {
				folder_closed = "",
				folder_open = "",
				folder_empty = "",
				default = "",
				highlight = "NeoTreeFileIcon",
			},
			modified = {
				symbol = "[+]",
				highlight = "NeoTreeModified",
			},
			name = {
				trailing_slash = false,
				use_git_status_colors = true,
				highlight = "NeoTreeFileName",
			},
			git_status = {
				symbols = {
					added = "",
					deleted = "",
					modified = "",
					renamed = "➜",
					untracked = "★",
					ignored = "◌",
					unstaged = "✗",
					staged = "✓",
					conflict = "",
				},
			},
		},
		window = {
			position = "left",
			width = 30,
			mapping_options = {
				noremap = true,
				nowait = true,
			},
			mappings = {
				["<leader>e"] = "close_window",
				["<2-LeftMouse>"] = "open",
				["<cr>"] = "open",
				["<esc>"] = "revert_preview",
				["P"] = { "toggle_preview", config = { use_float = true } },
				["p"] = { "toggle_preview", config = { use_float = true } },
				-- ["S"] = "open_split",
				-- ["s"] = "open_vsplit",
				["S"] = "split_with_window_picker",
				["s"] = "vsplit_with_window_picker",
				["v"] = "vsplit_with_window_picker",
				["h"] = "split_with_window_picker",
				["t"] = "open_tabnew",
				-- ["t"] = "open_tab_drop",
				["w"] = "open_with_window_picker",
				["C"] = "close_node",
				["z"] = "close_all_nodes",
				["Z"] = "expand_all_nodes",
				["a"] = { "add", config = { show_path = "none" } },
				["o"] = "open",
				["A"] = "add_directory", -- also accepts the optional config.show_path option like "add".
				["d"] = trash,
				["r"] = "rename",
				["y"] = "copy_to_clipboard",
				["x"] = "cut_to_clipboard",
				["c"] = "copy", -- takes text input for destination, also accepts the optional config.show_path option like "add":
				["m"] = "move", -- takes text input for destination, also accepts the optional config.show_path option like "add".
				["q"] = "close_window",
				["R"] = "refresh",
				["?"] = "show_help",
				["<"] = "prev_source",
				[">"] = "next_source",
				["/"] = "fuzzy_finder",
				["<bs>"] = function() end,
				["<Del>"] = trash,
			},
		},
		nesting_rules = {},
		filesystem = {
			filtered_items = {
				visible = false, -- when true, they will just be displayed differently than normal items
				hide_dotfiles = false,
				hide_gitignored = true,
				hide_hidden = true, -- only works on Windows for hidden files/directories
				hide_by_name = {
					"node_modules",
				},
				hide_by_pattern = { -- uses glob style patterns
					--"*.meta",
					--"*/src/*/tsconfig.json",
				},
				always_show = { -- remains visible even if other settings would normally hide it
					--".gitignored",
				},
				never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
					".DS_Store",
					"thumbs.db",
				},
				never_show_by_pattern = { -- uses glob style patterns
					--".null-ls_*",
				},
			},
			follow_current_file = true, -- This will find and focus the file in the active buffer every
			-- time the current file is changed while the tree is open.
			group_empty_dirs = false, -- wh"navigate_up"en true, empty folders will be grouped together
			hijack_netrw_behavior = "open_current", -- netrw disabled, opening a directory opens neo-tree
			-- in whatever position is specified in window.position
			-- "open_current",  -- netrw disabled, opening a directory opens within the
			-- window like netrw would, regardless of window.position
			-- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
			use_libuv_file_watcher = true, -- This will use the OS level file watchers to detect changes
			-- instead of relying on nvim autocmd events.
			window = {
				mappings = {
					["<bs>"] = function() end,
					["."] = "set_root",
					["H"] = "toggle_hidden",
					["/"] = "fuzzy_finder",
					["D"] = "fuzzy_finder_directory",
					["f"] = "filter_on_submit",
					["<c-x>"] = "clear_filter",
					["[g"] = "prev_git_modified",
					["]g"] = "next_git_modified",
				},
			},
		},
		buffers = {
			follow_current_file = true, -- This will find and focus the file in the active buffer every
			-- time the current file is changed while the tree is open.
			group_empty_dirs = true, -- when true, empty folders will be grouped together
			show_unloaded = true,
			window = {
				mappings = {
					["bd"] = "buffer_delete",
					["<bs>"] = "navigate_up",
					["."] = "set_root",
				},
			},
		},
		git_status = {
			window = {
				position = "float",
				mappings = {
					["A"] = "git_add_all",
					["gu"] = "git_unstage_file",
					["ga"] = "git_add_file",
					["gr"] = "git_revert_file",
					["gc"] = "git_commit",
					["gp"] = "git_push",
					["gg"] = "git_commit_and_push",
				},
			},
		},
		event_handlers = {
			{
				event = "vim_buffer_enter",
				handler = function(_)
					if vim.bo.filetype == "neo-tree" then vim.wo.signcolumn = "auto" end
				end,
			},
			{
				event = "file_opened",
				handler = function() neotree.close_all() end,
			},
		},
	})
end

local function config_dressing()
	local dressing = require("dressing")
	dressing.setup({
		input = {
			-- Set to false to disable the vim.ui.input implementation
			enabled = true,
			-- Default prompt string
			default_prompt = "➤ ",
			-- Can be 'left', 'right', or 'center'
			prompt_align = "left",
			-- When true, <Esc> will close the modal
			insert_only = true,
			-- When true, input will start in insert mode.
			start_in_insert = true,
			-- These are passed to nvim_open_win
			anchor = "SW",
			border = "rounded",
			-- 'editor' and 'win' will default to being centered
			relative = "cursor",
			-- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
			prefer_width = 40,
			width = nil,
			-- min_width and max_width can be a list of mixed types.
			-- min_width = {20, 0.2} means "the greater of 20 columns or 20% of total"
			max_width = { 140, 0.9 },
			min_width = { 20, 0.2 },
			-- Set to `false` to disable
			mappings = {
				n = {
					["<Esc>"] = "Close",
					["<CR>"] = "Confirm",
				},
				i = {
					["<C-c>"] = "Close",
					["<CR>"] = "Confirm",
					["<Up>"] = "HistoryPrev",
					["<Down>"] = "HistoryNext",
				},
			},

			override = function(conf)
				-- This is the config that will be passed to nvim_open_win.
				-- Change values here to customize the layout
				return conf
			end,

			-- see :help dressing_get_config
			get_config = function(opts)
				opts = opts or {}
				local cfg = {
					telescope = {
						layout_config = {
							width = 120,
							height = 25,
						},
					},
				}
				if opts.kind == "legendary.nvim" then
					cfg.telescope.sorter = require("telescope.sorters").fuzzy_with_index_bias({})
				end
				return cfg
			end,
		},
		select = {
			-- Set to false to disable the vim.ui.select implementation
			enabled = true,

			-- Priority list of preferred vim.select implementations
			backend = { "telescope", "fzf_lua", "fzf", "builtin", "nui" },

			-- Trim trailing `:` from prompt
			trim_prompt = true,

			-- Options for telescope selector
			-- These are passed into the telescope picker directly. Can be used like:
			-- telescope = require('telescope.themes').get_ivy({...})
			telescope = nil,

			-- Options for fzf selector
			fzf = {
				window = {
					width = 0.5,
					height = 0.4,
				},
			},

			-- Options for fzf_lua selector
			fzf_lua = {
				winopts = {
					width = 0.5,
					height = 0.4,
				},
			},

			-- Options for nui Menu
			nui = {
				position = "50%",
				size = nil,
				relative = "editor",
				border = {
					style = "rounded",
				},
				buf_options = {
					swapfile = false,
					filetype = "DressingSelect",
				},
				win_options = {
					winblend = 10,
				},
				max_width = 80,
				max_height = 40,
				min_width = 40,
				min_height = 10,
			},

			-- Options for built-in selector
			builtin = {
				-- These are passed to nvim_open_win
				anchor = "NW",
				border = "rounded",
				-- 'editor' and 'win' will default to being centered
				relative = "editor",

				win_opts = {
					-- Window transparency (0-100)
					winblend = 10,
					-- Change default highlight groups (see :help winhl)
					winhighlight = "",
				},
				-- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
				-- the min_ and max_ options can be a list of mixed types.
				-- max_width = {140, 0.8} means "the lesser of 140 columns or 80% of total"
				width = nil,
				max_width = { 140, 0.8 },
				min_width = { 40, 0.2 },
				height = nil,
				max_height = 0.9,
				min_height = { 10, 0.2 },

				-- Set to `false` to disable
				mappings = {
					["<Esc>"] = "Close",
					["<C-c>"] = "Close",
					["<CR>"] = "Confirm",
				},

				override = function(conf)
					-- This is the config that will be passed to nvim_open_win.
					-- Change values here to customize the layout
					return conf
				end,
			},

			-- Used to override format_item. See :help dressing-format
			format_item_override = {},

			-- see :help dressing_get_config
			get_config = nil,
		},
	})
end

local function config_telescope()
	local telescope = require("telescope")
	local actions = require("telescope.actions")
	telescope.setup({
		extensions = {
			fzf = {
				fuzzy = true, -- false will only do exact matching
				override_generic_sorter = true, -- override the generic sorter
				override_file_sorter = true, -- override the file sorter
				case_mode = "smart_case", -- or "ignore_case" or "respect_case"; the default case_mode is "smart_case"
			},
		},
		defaults = {

			prompt_prefix = " ",
			selection_caret = " ",
			path_display = { "smart" },
			file_ignore_patterns = { ".git/", "node_modules" },

			mappings = {
				i = {
					["<Down>"] = actions.cycle_history_next,
					["<Up>"] = actions.cycle_history_prev,
					["<C-j>"] = actions.move_selection_next,
					["<C-k>"] = actions.move_selection_previous,
				},
			},
		},
	})

	telescope.load_extension("fzf")
end

local function config_notify()
	local notify = require("notify")
	notify.setup({
		stages = "fade",
		background_colour = "#000000",
	})
	vim.notify = notify
end

local function config_bufferline()
	vim.opt.termguicolors = true
	require("bufferline").setup({
		options = {
			offsets = {
				{
					filetype = "neo-tree",
					text = "",
					highlight = "Directory",
				},
				{
					filetype = "NvimTree",
					text = "",
					highlight = "Directory",
				},
			},
		},
	})
end

local function config_noice()
	require("noice").setup({
		lsp = {
			-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true,
			},
		},
		-- you can enable a preset for easier configuration
		presets = {
			bottom_search = true, -- use a classic bottom cmdline for search
			command_palette = true, -- position the cmdline and popupmenu together
			long_message_to_split = true, -- long messages will be sent to a split
			inc_rename = false, -- enables an input dialog for inc-rename.nvim
			lsp_doc_border = false, -- add a border to hover docs and signature help
		},
	})
end

return function(use)
	use({ -- https://github.com/MunifTanjim/nui.nvim
		"MunifTanjim/nui.nvim",
	})

	use({ -- https://github.com/stevearc/dressing.nvim
		"stevearc/dressing.nvim",
		config = config_dressing,
	})
	use({
		"goolord/alpha-nvim",
		requires = { "nvim-tree/nvim-web-devicons" },
		config = function() require("alpha").setup(require("alpha.themes.startify").config) end,
	})
	use({ -- https://github.com/nvim-telescope/telescope-fzf-native.nvim
		"nvim-telescope/telescope-fzf-native.nvim",
		run = fzf_run,
	})

	use({ -- https://github.com/nvim-telescope/telescope.nvim
		"nvim-telescope/telescope.nvim",
		requires = {
			"nvim-telescope/telescope-fzf-native.nvim",
		},
		config = config_telescope,
	})

	use({ -- https://github.com/mrjones2014/smart-splits.nvim
		"mrjones2014/smart-splits.nvim",
		config = config_smart_splits,
	})
	use({ -- https://github.com/rcarriga/nvim-notify
		"rcarriga/nvim-notify",
		config = config_notify,
	})
	use({ "akinsho/bufferline.nvim", config = config_bufferline })

	use({ "nvim-neo-tree/neo-tree.nvim", branch = "v2.x", config = config_neo_tree })
	--  use({ "xiyaowong/nvim-transparent", config = config_transparent })
	use({
		"rebelot/heirline.nvim",
		requires = { "nvim-lualine/lualine.nvim" },
		after = { "bufferline.nvim" },
		config = function() require("plugins.heirline") end,
	})

	use({
		"folke/noice.nvim",
		config = config_noice,
		requires = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		},
	})
end
