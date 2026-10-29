local opt = vim.opt

-- Line numbers
opt.number = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
vim.wo.relativenumber = true


-- Search behaviour
opt.ignorecase = true
opt.smartcase = true

-- Appearance
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.winborder = "rounded"

-- Clipboard integration with Wayland
opt.clipboard = "unnamedplus"
