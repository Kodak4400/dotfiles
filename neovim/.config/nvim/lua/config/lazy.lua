-- 初期設定
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- プラグイン
require("lazy").setup({
  -- 1つ目: カラーテーマ (設定がなければ文字列のみ、または {} で囲むだけでOK)
  { 'EdenEast/nightfox.nvim' },
  -- 2つ目: Markdown描画プラグイン
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    ft = { 'markdown' },
    opts = {
      render_modes = { 'n', 'c', 't' },
    },
  },
  -- 3つ目: fzf-lua プラグイン
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("fzf-lua").setup({})
      local map = vim.keymap.set
      map("n", "<leader>ff", "<cmd>FzfLua files<CR>", { desc = "ファイル検索" })
      map("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>", { desc = "文字列検索" })
      map("n", "<leader>fb", "<cmd>FzfLua buffers<CR>", { desc = "バッファ検索" })
    end
  },
})

