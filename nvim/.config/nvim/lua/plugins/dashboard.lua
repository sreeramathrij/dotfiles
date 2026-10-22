return {
	{
		"goolord/alpha-nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VimEnter",
		config = function()
			local alpha = require("alpha")
			local dashboard = require("alpha.themes.dashboard")

			-- Color palette highlights matching the screenshot's low-contrast look
			local function set_hl()
				local link = function(name, to)
					vim.api.nvim_set_hl(0, name, { link = to })
				end
				link("AlphaGhostBorder", "Comment")
				link("AlphaGhostFill", "NonText")
				link("AlphaInfo", "Comment")
				link("AlphaButton", "Normal")
				link("AlphaShortcut", "Comment")
				link("AlphaFooter", "NonText")
			end
			set_hl()
			vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })

			-- Ghost sprite matching the shaded Pacman ghost in the reference image
			-- X = Outer border, : = Textured body fill, . = Background
			local sprite_raw = {
				"......XXX......",
				"....XX:::XX....",
				"...X:::::::X...",
				"..X:::::::::X..",
				".X::::..::::...",
				".X:::.:X:::.XX.",
				".X:::.:X:::.:X.",
				"X:::::..::::..X",
				"X:::::::::::::X",
				"X:::::::::::::X",
				"X:::::::::::::X",
				"X:::::::::::::X",
				"X:X:::X::::X::X",
				"XX.X:X.X::X.X:X",
				"X...X...XX...XX",
			}

			local ghost = {}
			for _, row in ipairs(sprite_raw) do
				local line = row:gsub("X", "██"):gsub(":", "░░"):gsub("%.", "  ")
				table.insert(ghost, line)
			end

			-- Info box: two lines padded to the same width
			local function box(l1, l2)
				local w = math.max(vim.fn.strdisplaywidth(l1), vim.fn.strdisplaywidth(l2))
				local pad = function(s)
					return s .. string.rep(" ", w - vim.fn.strdisplaywidth(s))
				end
				return { "┌ " .. pad(l1) .. " ┐", "└ " .. pad(l2) .. " ┘" }
			end
			local info = box(os.date("Today is %a %d %b"), require("lazy").stats().count .. " plugins in total")

			-- Nerd Font icons by codepoint (avoids pasting glyphs)
			local icon = function(cp)
				return vim.fn.nr2char(cp)
			end
			local function button(key, cp, label, cmd)
				local b = dashboard.button(key, icon(cp) .. "  " .. label, cmd)
				b.opts.width = 36
				b.opts.hl = "AlphaButton"
				b.opts.hl_shortcut = "AlphaShortcut"
				return b
			end

			local buttons = {
				button("SPC f r", 0xf1da, "Recents", "<cmd>Telescope oldfiles<cr>"),
				button("SPC f b", 0xf15c, "Buffers", "<cmd>Telescope buffers<cr>"),
				button("SPC e", 0xf07b, "Explore", "<cmd>Neotree toggle<cr>"),
				button("SPC f g", 0xf002, "Ripgrep", "<cmd>Telescope live_grep<cr>"),
				button(
					"SPC f c",
					0xf013,
					"Config",
					"<cmd>lua require('telescope.builtin').find_files({ cwd = vim.fn.stdpath('config') })<cr>"
				),
				button("SPC l", 0xf1b3, "Plugins", "<cmd>Lazy<cr>"),
				button("q", 0xf011, "Quit", "<cmd>qa<cr>"),
			}

			local v = vim.version()
			local footer = string.format("nvim v%d.%d.%d", v.major, v.minor, v.patch)

			-- Vertical centering: ghost 14 + info 2 + buttons 13 + footer 1 + 3 gaps of 2
			local content_height = #ghost + 2 + (#buttons * 2 - 1) + 1 + 6
			local top = math.max(0, math.floor((vim.o.lines - content_height) / 2))

			local text = function(val, hl)
				return { type = "text", val = val, opts = { position = "center", hl = hl } }
			end

			dashboard.config.layout = {
				{ type = "padding", val = top },
				text(ghost, "AlphaGhost"),
				{ type = "padding", val = 2 },
				text(info, "AlphaInfo"),
				{ type = "padding", val = 2 },
				{ type = "group", val = buttons, opts = { spacing = 1 } },
				{ type = "padding", val = 2 },
				text(footer, "AlphaFooter"),
			}

			alpha.setup(dashboard.config)
		end,
	},
}
