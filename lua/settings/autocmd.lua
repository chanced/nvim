vim.api.nvim_create_autocmd("BufWritePost", {
	group = vim.api.nvim_create_augroup("PackerCompiler", { clear = true }),
	pattern = "*.lua",
	command = "source <afile> | PackerCompile | LuaCacheClear",
})

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = {
		"*.lua",
	},
	command = "source ~/.config/nvim/init.lua",
})
