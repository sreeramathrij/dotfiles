return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then
        return
      end

      -- Force git cloning instead of downloading tarballs
      require("nvim-treesitter.install").prefer_git = true

      configs.setup({
        ensure_installed = {
          "c",
          "cpp",
          "css",
          "html",
          "java",
          "javascript",
          "typescript",
          "tsx",
          "yaml",
          "toml",
          "qmljs",
          "rust",
          "lua",
          "luadoc",
          "vim",
          "vimdoc",
          "bash",
          "toml",
          "json",
          "yaml",
          "markdown",
          "markdown_inline",
          "regex",
        },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
      })
    end,
  },
}
