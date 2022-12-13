local colorscheme = "nightfox"
local ok, _ = pcall(require, colorscheme)
if ok then
	vim.cmd("colorscheme " .. colorscheme)
else
	print("colorscheme not found")
end
require("plugins")
require("settings")

local keymap = require("util").keymap
keymap("n", "<c+.>", function() print("c-.") end, ".")
