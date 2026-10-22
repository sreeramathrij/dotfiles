return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "lua_ls",
        "clangd",
        "rust_analyzer",
        "ts_ls",
        "html",
        "cssls",
        "jsonls",
        "bashls",
        "yamlls",
        "taplo",
      },
      automatic_enable = { exclude = { "emmylua_ls", "ast_grep" } },
    },
  },
  {
    -- config lives here
    "neovim/nvim-lspconfig",
    config = function()
      -- Make lua_ls aware of globals
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
          },
        }
      })

      -- QML (Quickshell): not in Mason
      vim.lsp.config("qmlls", {cmd = { "qmlls6" } })
      vim.lsp.enable("qmlls")

      vim.diagnostic.config({
        virtual_text = true,
        severity_sort = true,
      })

      -- Keymaps only when a server attaches to the buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local map = function(keys, fn, desc)
            vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = "LSP: " .. desc })
          end
            map("gd", vim.lsp.buf.definition, "Go to definition")
            map("K", function()
              vim.lsp.buf.hover({ max_width = 80, max_height = 25 })
            end, "Hover for manual")
            map("gD", vim.lsp.buf.declaration, "Go to declaration")
            map("<leader>rn", vim.lsp.buf.rename, "Rename")
            map("<leader>ca", vim.lsp.buf.code_action, "Code actions")
            map("<leader>d", vim.diagnostic.open_float, "Line diagnostics")
            map("<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Format Selection")
        end,
      })
    end,
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      libbrary = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
}
