return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")

      telescope.setup({
        defaults = {
          path_display = { "truncate" },
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
            },
          },
        },
      })

      -- Load native sorter extension
      pcall(telescope.load_extension, "fzf")

      -- Keymaps (Leader is <Space>)
      local map = vim.keymap.set
      map("n", "<leader>ff", function()
        builtin.find_files({ hidden = true })
      end, { desc = "Find files" })
      map("n", "<leader>fg", function()
        builtin.live_grep({ additional_args = { "--hidden" } })
      end, { desc = "Live grep (search text)" })
      map("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      map("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
      map("n", "<leader>fc", function()
        builtin.find_files({ cwd = vim.fn.stdpath("config") })
      end, { desc = "Find Neovim config files" })
    end,
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      require("telescope").setup({
        extenstions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({})
          }
        }
      })
      require("telescope").load_extension("ui-select")
    end
  }
}
