return function(use)
	use { -- https://github.com/rmagatti/auto-session
		'rmagatti/auto-session',
		config = function()
			require("auto-session").setup {
				log_level = "error",
				auto_session_suppress_dirs = { "~/", "~/dev", "~/Downloads", "/" },
			}
		end
	}
	use { -- https://github.com/rmagatti/session-lens
		"rmagatti/session-lens",
		config = function()
			require("session-lens").setup()
			require("telescope").load_extension("session-lens")
		end,
		requires = { "rmagatti/auto-session", "nvim-telescope/telescope.nvim" }
	}
end
