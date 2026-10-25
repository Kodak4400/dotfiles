-- マウス左クリック離し（<LeftRelease>）でのトグル
vim.keymap.set('n', '<LeftRelease>', function()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]

  local box_start, box_end = line:find('%[%s%]')
  if not box_start then
    box_start, box_end = line:find('%[x%]')
  end

  if box_start and box_end and col >= box_start - 3 and col <= box_end then
    if line:match('%[ %]') then
      -- 修正: () で囲んで最初の戻り値（文字列）だけを渡す
      vim.api.nvim_set_current_line((line:gsub('%[ %]', '[x]', 1)))
    elseif line:match('%[x%]') then
      vim.api.nvim_set_current_line((line:gsub('%[x%]', '[ ]', 1)))
    end
  end
end, { buffer = true, silent = true, desc = "Toggle Markdown Checkbox with Mouse" })

-- Enterキー（<CR>）でのトグル
vim.keymap.set('n', '<CR>', function()
  local line = vim.api.nvim_get_current_line()
  if line:match('%[ %]') then
    -- 修正: () で囲む
    vim.api.nvim_set_current_line((line:gsub('%[ %]', '[x]', 1)))
  elseif line:match('%[x%]') then
    -- 修正: () で囲む
    vim.api.nvim_set_current_line((line:gsub('%[x%]', '[ ]', 1)))
  end
end, { buffer = true, silent = true, desc = "Toggle Markdown Checkbox" })

-- マウスカーソルで選択時にクリップボードへコピー
-- マウス操作を有効にする（Neovimではデフォルトで有効な場合が多いです）
vim.opt.mouse = 'a'

-- クリップボードをOSと共有する（Neovimの場合、OS問わず 'unnamedplus' を推奨します）
vim.opt.clipboard = 'unnamedplus'

-- 左クリックを離した瞬間にクリップボード("+レジスタ)へコピーし、選択状態を維持する
vim.keymap.set('v', '<LeftRelease>', '"+ygv', { noremap = true, silent = true })

