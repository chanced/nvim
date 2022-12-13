return function(use)
	use "DaikyXendo/nvim-material-icon"
	use {
		"nvim-tree/nvim-web-devicons",
		config = function()
			local web_devicons_ok, web_devicons = pcall(require, "nvim-web-devicons")
			if not web_devicons_ok then
				return
			end
			local material_icon_ok, material_icon = pcall(require, "nvim-material-icon")
			if not material_icon_ok then
				return
			end
			web_devicons.setup({
				override = material_icon.get_icons(),
			})
		end
	}
	use { "ziontee113/icon-picker.nvim",
		config = function()
			vim.defer_fn(function()
				require("icon-picker").setup({
					disable_legacy_commands = true
				})
			end, 1000)
		end
	}
end
