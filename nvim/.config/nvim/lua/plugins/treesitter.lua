return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- main branch doesn't support lazy-loading
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      ts.setup({ auto_install = true })

      ts.install({
        "c", "cpp", "css", "html", "java", "javascript", "typescript", "tsx",
        "yaml", "toml", "qmljs", "rust", "lua", "luadoc", "vim", "vimdoc",
        "bash", "json", "markdown", "markdown_inline", "regex",
      })

      -- highlighting and indent are opt-in per filetype now
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match)
          if lang and pcall(vim.treesitter.start, ev.buf, lang) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
