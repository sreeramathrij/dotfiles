return {
  {
    "arnamak/stay-centered.nvim",
    lazy = false,
    opts = {
      skip_filetypes = { "neo-tree", "toggleterm", 'alpha', "TelescopePrompt" },
    enabled = true,
    },
    keys = {
      {
        "<leader>ut",
        function() require("stay-centered").toggle() end,
        desc = "Toggle Stay Centered",
      },
    },
  },
}
