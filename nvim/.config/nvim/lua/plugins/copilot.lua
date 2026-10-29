return {
	{
		"github/copilot.vim",
		config = function()
			vim.keymap.set("n", "<leader>ct", function()
				if vim.b.copilot_enabled == 0 or vim.g.copilot_enabled == false then
					vim.cmd("Copilot enable")
					vim.b.copilot_enabled = 1
					vim.g.copilot_enabled = true
					print("Copilot: Enabled")
				else
					vim.cmd("Copilot disable")
					vim.b.copilot_enabled = 0
					vim.g.copilot_enabled = false
					print("Copilot: Disabled")
				end
			end, { desc = "Toggle Copilot" })
		end,
	},
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				suggestion = {
					enabled = true,
					auto_trigger = true,
					keymap = {
						accept = "<M-l>",
						next = "<M-]>",
						prev = "<M-[>",
						dismiss = "<C-]>",
					},
				},
				filetypes = {
					markdown = true,
					help = false,
					gitcommit = false,
				},
			})
		end,
	},
}
