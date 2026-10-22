return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size = 15,
      open_mapping = [[<C-\>]],
      direction = "horizontal", -- like VSCode bottom panel
      shade_terminals = true,
      insert_mappings = true,
      terminal_mappings = true,
      float_opts = {
        border = "curved",
      },
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)

      -- Standardize terminal escape behaviour
      local map = function(keybind, cmd, desc)
        vim.keymap.set("t", keybind, cmd, { desc = desc } )
      end

      map("<Esc><Esc>", [[<C-\><C-n>]], "Exit terminal mode")
      map("<C-h>", [[<Cmd>wincmd h<CR>]], "Move to left window")
      map("<C-j>", [[<Cmd>wincmd j<CR>]], "Move to down window")
      map("<C-k>", [[<Cmd>wincmd k<CR>]], "Move to up window")
      map("<C-l>", [[<Cmd>wincmd l<CR>]], "Move to right window")
    end
  }
}
