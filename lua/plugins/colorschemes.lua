return function(use)
	use("rebelot/kanagawa.nvim")
	use({
		"olimorris/onedarkpro.nvim",

		config = function()
			require("onedarkpro").setup({
				options = {
					transparency = true,
				},
			})
		end,
	})
	use({
		"EdenEast/nightfox.nvim",
		config = function()
			require("nightfox").setup({
				options = {
					transparent = true,
				},
			})
		end,
	})
end
