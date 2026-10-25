vim.g.mapleader = " "

-- 行番号
vim.opt.number = true
-- vim.opt.relativenumber = true

-- インデント
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- 検索
vim.opt.ignorecase = true
vim.opt.smartcase = true

require("config.lazy")
require("config.options")

vim.cmd("colorscheme nightfox")
