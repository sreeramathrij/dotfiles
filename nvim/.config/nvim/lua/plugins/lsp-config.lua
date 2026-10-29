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
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Array of all servers to be enabled
      local servers = {
        "clangd", "rust_analyzer", "ts_ls", "html", 
        "cssls", "jsonls", "bashls", "yamlls", "taplo", "lua_ls", "qmlls"
      }

      -- 1. Apply baseline capabilities to all servers natively
      for _, lsp in ipairs(servers) do
        vim.lsp.config(lsp, {
          capabilities = capabilities,
        })
      end

      -- 2. Apply specific overrides
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
          },
        },
      })

      -- vim.lsp.config("qmlls", {
      --  cmd = { "qmlls6" },
      --  capabilities = capabilities,
      -- })

      -- 3. Enable all servers at once using the native 0.11 API
      vim.lsp.enable(servers)

      vim.diagnostic.config({
        virtual_text = true,
        severity_sort = true,
      })

      -- Keymaps bound when a server attaches
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local map = function(keys, fn, desc)
            vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = "LSP: " .. desc })
          end
          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("K", function() vim.lsp.buf.hover({ max_width = 80, max_height = 25 }) end, "Hover for manual")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("<leader>rn", vim.lsp.buf.rename, "Rename")
          map("<leader>ca", vim.lsp.buf.code_action, "Code actions")
          map("<leader>d", vim.diagnostic.open_float, "Line diagnostics")
          map("<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Format Selection")
        end,
      })

      vim.api.nvim_create_user_command("LspRestart", function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        for _, client in ipairs(clients) do
          local name = client.name
          client:stop()
          vim.defer_fn(function()
            vim.lsp.enable(name, false)
            vim.lsp.enable(name, true)
            vim.cmd("edit")
          end, 500)
        end
      end, { desc = "Restart native Neovim 0.11 LSP client for current buffer" })

    end
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
}
