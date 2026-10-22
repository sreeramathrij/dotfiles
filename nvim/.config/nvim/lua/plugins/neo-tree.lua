return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		lazy = false,
		cmd = "Neotree",
		keys = {
			{ "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree sidebar" },
			{ "<leader>o", "<cmd>Neotree focus<cr>", desc = "Focus Neo-tree sidebar" },
		},
		opts = {
			close_if_last_window = true,
			popup_border_style = "solid",
			filesystem = {
				filtered_items = {
					visible = true,
					hide_dotfiles = false,
					hide_gitignored = false,
				},
				follow_current_file = {
					enabled = true,
					leave_dirs_open = false,
				},
				use_libuv_file_watcher = true,
			},
			window = {
				position = "left",
				width = 30,
				mappings = {
					["<space>"] = "none",
					["l"] = "open",
					["h"] = "close_node",
					["<cr>"] = "open",
					["a"] = {
						"add",
						config = {
							show_path = "none",
						},
					},
					["d"] = "delete",
					["r"] = "rename",
					["y"] = "copy_to_clipboard",
					["x"] = "cut_to_clipboard",
					["p"] = "paste_from_clipboard",
					["c"] = "copy",
					["m"] = "move",
					["q"] = "close_window",
					["R"] = "refresh",
					["?"] = "show_help",
				},
			},
			default_component_configs = {
				indent = {
					with_expanders = true,
					expander_collapsed = "",
					expander_expanded = "",
				},
				git_status = {
					symbols = {
						added = "+",
						modified = "~",
						deleted = "x",
						renamed = "➜",
						untracked = "?",
						ignored = "◌",
						unstaged = "!",
						staged = "✓",
						conflict = "",
					},
				},
			},
		},
	},
}
