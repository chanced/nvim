--
-- Functional wrapper for mapping custom keybindings
local n = "n"
local i = "i"
local v = "v"
local x = "x"
local o = "o"
local keymap = require("util").keymap
--keymap(n, "©+,", '<cmd>lua print("c+,")<cr>', "test")
keymap(n, "<leader><Space>", "<Nop>", "")

keymap(
	{ n, v },
	"gx",
	"<Cmd>call jobstart(['open', expand('<cfile>')], {'detach': v:true})<CR>",
	"Open addr under cursor with system app"
)
keymap(n, "<leader>f", "<cmd>Telescope find_files<cr>", "File Fuzzy Finder")
keymap(n, "<leader>ff", "<cmd>Telescope find_files<cr>", "File Fuzzy Finder")
keymap(n, "<leader>fr", "<cmd>Telescope oldfiles<cr>", "Open Recent File")
keymap(
	n,
	"<C-S-l>",
	"<cmd>nohlsearch<cr><cmd>mode<cr><cmd>diffupdate<cr>",
	"Clears and redraws the screen."
)
keymap(n, "\\", "<cmd>Neotree toggle<cr>", "Toggle File Explorer")
keymap(n, "|", "<cmd>Neotree show focus<cr>", "Show and focus File Explorer")
keymap(n, "<leader>e", "<cmd>Neotree toggle<cr>", "Toggle File Explorer")

local telescope_ok, telescope_builtin = pcall(require, "telescope.builtin")
if telescope_ok then
	keymap(n, "<C-p>", "<cmd>Telescope find_files<cr>", "File Fuzzy Finder")
	keymap(n, "<C-f>", telescope_builtin.live_grep, "Grep")
end

local smart_splits_ok, smart_splits = pcall(require, "smart-splits")
if smart_splits_ok then
	keymap(n, "<C-h>", smart_splits.move_cursor_left, "Move to left split")
	keymap(n, "<C-j>", smart_splits.move_cursor_down, "Move to below split")
	keymap(n, "<C-k>", smart_splits.move_cursor_up, "Move to above split")
	keymap(n, "<C-l>", smart_splits.move_cursor_right, "Move to right split")
end

keymap(n, "<c-}>", "<cmd>BufferLineCycleNext<cr>", "Next buffer")
keymap(n, "<c-{>", "<cmd>BufferLineCyclePrev<cr>", "Previous buffer")
keymap(n, "<c-s-]>", "<cmd>BufferLineCycleNext<cr>", "Next buffer")
keymap(n, "<c-s-[>", "<cmd>BufferLineCyclePrev<cr>", "Previous buffer")

local bufdel_ok, bufdel = pcall(require, "bufdelete")
if bufdel_ok then
	local close = function() bufdel.bufdelete(0, false) end
	local force_close = function() bufdel.bufdelete(0, true) end
	keymap(n, "<leader>x", function() bufdel.bufdelete(0, false) end, "Close buffer")
	keymap(n, "<leader>X", function() bufdel.bufdelete(0, true) end, "Force close buffer")
	keymap(n, "<leader>c", close, "Close buffer")
end

-- Keymaps for Luasnip
local luasnip_ok, luasnip = pcall(require, "luasnip")
if luasnip_ok then
	vim.keymap.set({ "i", "s" }, "<tab>", function()
		if luasnip.expand_or_jumpable() then luasnip.expand_or_jump() end
	end, { silent = true })
	vim.keymap.set({ "i", "s" }, "<C-h>", function()
		if luasnip.jumpable(-1) then luasnip.jump(-1) end
	end, { silent = true })
	vim.keymap.set("i", "<C-l>", function()
		if luasnip.choice_active() then luasnip.change_choice(1) end
	end)
end

keymap({ n, x, o }, "x", function() require("leap-ast").leap() end, "Leap AST")

keymap(n, "<c-s-a>", function() print("ctrl-shift-a") end, "ctrl-shift-a")
