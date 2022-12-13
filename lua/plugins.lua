local impatient_ok, impatient = pcall(require, "impatient")
if impatient_ok then impatient.enable_profile() end
local function is_file(check, filename)
	for i, name in ipairs(check) do
		if vim.endswith(filename, name) then return { true, i } end
	end
	return { false }
end

-- auto install packer if not installed
local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({
			"git",
			"clone",
			"--depth",
			"1",
			"https://github.com/wbthomason/packer.nvim",
			install_path,
		})
		vim.cmd([[packadd packer.nvim]])
		return true
	end
	return false
end
local packer_bootstrap = ensure_packer() -- true if packer was just installed
local util = require("util")
local join_paths = util.join_paths
local compile_path = join_paths(vim.fn.stdpath("data"), "plugin", "packer_compiled.lua")
local compiled, _ = loadfile(compile_path)
if compiled then
	compiled()
else
	print("compiled not found")
end
local ok, packer = pcall(require, "packer")
if not ok then
	print("Packer not found")
	return
end

packer.init({
	package_root = join_paths(vim.fn.stdpath("data"), "site", "pack"),
	compile_path = compile_path,
	plugin_package = "packer",
	display = { open_fn = require("packer.util").float },
	max_jobs = 13,
	auto_clean = true,
	compile_on_sync = true,
})

local load_plugins = function(use)
	use("wbthomason/packer.nvim")
	use({ "nvim-lua/plenary.nvim" })
	-- use({ "MunifTanjim/nui.nvim" })
	-- local preload = {
	-- 	"util",
	-- 	"ui",
	-- 	"colorschemes",
	-- }
	-- for _, plugin in ipairs(preload) do
	-- 	require("plugins." .. plugin)(use)
	-- end
	-- The following code loads our plugins based on their category group (e.g. autocomplete, lsp, search etc).
	local plugins = vim.api.nvim_get_runtime_file("lua/plugins/*.lua", true)
	-- local loaded = {}
	-- for i, plugin in ipairs(preload) do
	-- 	loaded[i] = plugin .. ".lua"
	-- end
	for _, abspath in ipairs(plugins) do
		for _, filename in ipairs(vim.split(abspath, "/lua/", { trimempty = true })) do
			if vim.endswith(filename, ".lua") then
				-- local res = is_file(loaded, filename)
				-- if not res[1] then
				for _, name in ipairs(vim.split(filename, "[.]lua", { trimempty = true })) do
					require(name)(use)
				end
			end
			-- else
			-- 	print("removing", res[2])
			-- 	table.remove(loaded, res[2])
			-- end
		end
	end
end

-- autocommand that reloads neovim and installs/updates/removes plugins
-- when file is saved
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])
-- add list of plugins to install
return packer.startup(function(use)
	load_plugins(use)
	if packer_bootstrap then packer.sync() end
end)
