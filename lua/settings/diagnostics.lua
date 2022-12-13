local signs = {
	{ name = "Diagnostic", text = "裂" },
	{ name = "DiagnosticSignError", text = "" },
	{ name = "DiagnosticSignWarn", text = "" },
	{ name = "DiagnosticSignHint", text = "" },
	{ name = "DiagnosticSignInfo", text = "" },
	{ name = "DapStopped", text = "", texthl = "DiagnosticWarn" },
	{ name = "DapBreakpoint", text = "", texthl = "DiagnosticInfo" },
	{ name = "DapBreakpointRejected", text = "", texthl = "DiagnosticError" },
	{ name = "DapBreakpointCondition", text = "", texthl = "DiagnosticInfo" },
	{ name = "DapLogPoint", text = "", texthl = "DiagnosticInfo" },
}

vim.diagnostic.config({
	virtual_text = true,
	signs = { active = signs },
	update_in_insert = true,
	underline = true,
	severity_sort = true,
	float = {
		focused = false,
		style = "minimal",
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
})

for _, sign in ipairs(signs) do
	vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end
