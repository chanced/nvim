local function config_stickybuf()
	require("stickybuf").setup({
		-- "bufnr" will pin the exact buffer (PinBuffer)
		-- "buftype" will pin the buffer type (PinBuftype)
		-- "filetype" will pin the filetype (PinFiletype)
		buftype = {
			[""]     = false,
			acwrite  = false,
			help     = "buftype",
			nofile   = false,
			nowrite  = false,
			quickfix = "buftype",
			terminal = false,
			prompt   = "bufnr",
		},
		wintype = {
			autocmd  = false,
			popup    = "bufnr",
			preview  = false,
			command  = false,
			[""]     = false,
			unknown  = false,
			floating = false,
		},
		filetype = {
			aerial = "filetype",
			nerdtree = "filetype",
			["neotest-summary"] = "filetype",
		},
		bufname = {
			["Neogit.*Popup"] = "bufnr",
		},
		-- Some autocmds for plugins that need a bit more logic
		-- Set to `false` to disable the autocmd
		autocmds = {
			-- Only pin defx if it was opened as a split (has fixed height/width)
			defx = [[au FileType defx if &winfixwidth || &winfixheight | silent! PinFiletype | endif]],
			-- Only pin fern if it was opened as a split (has fixed height/width)
			fern = [[au FileType fern if &winfixwidth || &winfixheight | silent! PinFiletype | endif]],
			-- Only pin neogit if it was opened as a split (there is more than one window)
			neogit = [[au FileType NeogitStatus,NeogitLog,NeogitGitCommandHistory if winnr("$") > 1 | silent! PinFiletype | endif]],
		}
	})
end

local function config_window_picker()
	require("window-picker").setup({
		autoselect_one = true,
		include_current = false,
		filter_rules = {
			-- filter using buffer options
			bo = {
				-- if the file type is one of following, the window will be ignored
				filetype = { "neo-tree", "neo-tree-popup", "notify" },
				-- if the buffer type is one of following, the window will be ignored
				buftype = { "terminal", "quickfix" },
			},
		},
		other_win_hl_color = "#e35e4f",
	})
end

return function(use)
	-- Delete Neovim buffers without losing window layout
	use { -- https://github.com/famiu/bufdelete.nvim
		"famiu/bufdelete.nvim",
	}

	-- Neovim plugin for locking a buffer to a window
	use { -- https://github.com/stevearc/stickybuf.nvim
		"stevearc/stickybuf.nvim", -- Buffer lock
		config = config_stickybuf,
	}

	-- This plugins prompts the user to pick a window and returns the window id
	-- of the picked window
	use { -- https://github.com/s1n7ax/nvim-window-picker
		"s1n7ax/nvim-window-picker",
		config = config_window_picker,
	}
end
