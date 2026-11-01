return {
    {
        "lervag/vimtex",

        -- Do not lazy-load VimTeX.
        lazy = false,

        init = function()
            vim.g.vimtex_view_method = "zathura"
            vim.g.vimtex_compiler_method = "latexmk"

            -- Keep compilation errors accessible.
            vim.g.vimtex_quickfix_mode = 2

            -- Configure continuous compilation.
            vim.g.vimtex_compiler_latexmk = {
                continuous = 1,
                callback = 1,
                options = {
                    "-pdf",
                    "-synctex=1",
                    "-interaction=nonstopmode",
                    "-file-line-error",
                },
            }
        end,
    },
}
