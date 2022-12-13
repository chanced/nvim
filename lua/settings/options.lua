vim.g.copilot_node_command = "~/.nvm/v16.18.1/bin/node"
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.wrap = false
vim.g.mapleader = " "
vim.opt.sidescroll = 1
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
vim.opt.smartindent = true
vim.opt.timeoutlen = 700
vim.opt.ttimeoutlen = 50
vim.opt.splitbelow = true
vim.opt.syntax = "on"
vim.opt.modeline = true
vim.opt.autochdir = false
vim.opt.diffopt = "vertical"
vim.opt.splitright = true
vim.opt.clipboard = "unnamedplus"
vim.o.completeopt = "menuone,noinsert,noselect"
vim.opt.termguicolors = true
vim.opt.ignorecase = true -- ignore case in search patterns
vim.opt.smartcase = true -- smartcase
vim.opt.fileencoding = "utf-8" -- File content encoding for the buffer
vim.opt.writebackup = false
vim.opt.swapfile = false -- Disable use of swapfile for the buffer
vim.opt.undofile = true
vim.opt.backup = false -- creates a backup file
vim.opt.ruler = false
vim.opt.cursorline = true -- highlight the current line
vim.opt.scrolloff = 8 -- minimal number of screen lines to keep above and below the cursor
vim.opt.sidescrolloff = 8 -- minimal number of screen columns to keep to the left and right of the cursor if wrap is `false`
vim.opt.shortmess:append("c") -- hide all the completion messages, e.g. "-- XXX completion (YYY)", "match 1 of 2", "The only match", "Pattern not found"
vim.opt.whichwrap:append("<,>,[,],h,l") -- keys allowed to move to the previous/next line when the beginning/end of line is reached
vim.opt.iskeyword:append("-") -- treats words with `-` as single words
-- vim.opt.formatoptions:remove { "c", "r", "o" } -- This is a sequence of letters which describes how automatic formatting is to be done
vim.opt.linebreak = true
vim.opt.termguicolors = true
vim.opt.laststatus = 3 -- only the last window will always have a status line
--vim.opt.showcmd = false -- hide (partial) command in the last line of the screen (for performance)
vim.opt.ruler = false -- hide the line and column number of the cursor position
vim.opt.shortmess = vim.opt.shortmess + "c" -- avoid showing extra messages when using completion
vim.opt.cmdheight = 0
vim.opt.foldmethod = "manual"
vim.filetype.add({
	pattern = {
		["*.jsonc"] = "jsonc",
		["tsconfig.json"] = "jsonc",
		["tsconfig*.json"] = "jsonc",
	},
})
