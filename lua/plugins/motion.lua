return function(use)
	use({ "ggandor/lightspeed.nvim", config = function() require("lightspeed").setup({}) end })
	use("tpope/vim-repeat")
	use({
		"kylechui/nvim-surround",
		config = function() require("nvim-surround").setup({}) end,
	})
end
