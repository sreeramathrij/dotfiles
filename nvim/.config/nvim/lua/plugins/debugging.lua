return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			local dap, dapui = require("dap"), require("dapui")

			dapui.setup()

			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end

			-- Debugger Keybinds
			-- Breakpoints
			vim.keymap.set("n", "<Leader>dt", dap.toggle_breakpoint, { desc = "Debugger: Conditional Breakpoint" })
			vim.keymap.set("n", "<Leader>dB", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, { desc = "Debugger: Conditional Breakpoint" })

			-- Execution control
			vim.keymap.set("n", "<Leader>dc", dap.continue, { desc = "Debugger: Start/Continue" })
			vim.keymap.set("n", "<Leader>do", dap.step_over, { desc = "Debugger: Step Over" })
			vim.keymap.set("n", "<Leader>di", dap.step_into, { desc = "Debugger: Step Into" })
			vim.keymap.set("n", "<Leader>dO", dap.step_out, { desc = "Debugger: Step Out" })
			vim.keymap.set("n", "<Leader>dx", dap.terminate, { desc = "Debugger: Terminate" })

			-- UI and Inspection
			vim.keymap.set("n", "<Leader>du", dapui.toggle, { desc = "Debugger: Toggle UI" })
			vim.keymap.set("n", "<Leader>dr", dap.repl.toggle, { desc = "Debugger: Toggle REPL" })

			-- C/C++/Rust Debugger Setup
			dap.adapters.gdb = {
				type = "executable",
				command = "gdb",
				args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
			}
			dap.configurations.c = {
				{
					name = "Launch",
					type = "gdb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					args = {}, -- provide arguments if needed
					cwd = "${workspaceFolder}",
					stopAtBeginningOfMainSubprogram = false,
				},
				{
					name = "Select and attach to process",
					type = "gdb",
					request = "attach",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					pid = function()
						local name = vim.fn.input("Executable name (filter): ")
						return require("dap.utils").pick_process({ filter = name })
					end,
					cwd = "${workspaceFolder}",
				},
				{
					name = "Attach to gdbserver :1234",
					type = "gdb",
					request = "attach",
					target = "localhost:1234",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
				},
			}
			dap.configurations.cpp = dap.configurations.c
			dap.configurations.rust = dap.configurations.c
		end,
	},
}
