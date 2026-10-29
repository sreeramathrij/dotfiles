return {
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    opts = {
      -- Ignore sidebars and special buffers when calculating resize boundaries
      ignored_filetypes = { "neo-tree", "NvimTree" },
      ignored_buftypes = { "nofile", "quickfix", "prompt" },
      -- Stop at the outer edge instead of wrapping around or spawning unwanted splits
      at_edge = "stop",
    },
    config = function(_, opts)
      local smart_splits = require("smart-splits")
      smart_splits.setup(opts)

      -- Open new splits to the right and bottom by default
      vim.opt.splitright = true
      vim.opt.splitbelow = true

      -- 1. Explicit Split Creation & Closing (<leader>s...)
      vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
      vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
      vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
      vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

      -- 2. Seamless Directional Navigation (Ctrl + h/j/k/l)
      vim.keymap.set("n", "<C-h>", smart_splits.move_cursor_left, { desc = "Move to left split" })
      vim.keymap.set("n", "<C-j>", smart_splits.move_cursor_down, { desc = "Move to bottom split" })
      vim.keymap.set("n", "<C-k>", smart_splits.move_cursor_up, { desc = "Move to top split" })
      vim.keymap.set("n", "<C-l>", smart_splits.move_cursor_right, { desc = "Move to right split" })

      -- Allow jumping straight out of an open toggleterm terminal back up to code
      vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], { desc = "Jump from terminal to code" })

      -- 3. Intuitive Directional Resizing (Alt + h/j/k/l)
      vim.keymap.set("n", "<A-h>", smart_splits.resize_left, { desc = "Resize split left" })
      vim.keymap.set("n", "<A-j>", smart_splits.resize_down, { desc = "Resize split down" })
      vim.keymap.set("n", "<A-k>", smart_splits.resize_up, { desc = "Resize split up" })
      vim.keymap.set("n", "<A-l>", smart_splits.resize_right, { desc = "Resize split right" })

      -- 4. Bonus: Swap Open Buffers Between Splits (<leader><leader> + h/j/k/l)
      vim.keymap.set("n", "<leader><leader>h", smart_splits.swap_buf_left, { desc = "Swap buffer left" })
      vim.keymap.set("n", "<leader><leader>j", smart_splits.swap_buf_down, { desc = "Swap buffer down" })
      vim.keymap.set("n", "<leader><leader>k", smart_splits.swap_buf_up, { desc = "Swap buffer up" })
      vim.keymap.set("n", "<leader><leader>l", smart_splits.swap_buf_right, { desc = "Swap buffer right" })
    end,
  },
}
