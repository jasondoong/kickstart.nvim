-- 使用縮排作為摺疊方式
vim.opt.foldmethod = "indent"
-- 預設開啟所有摺疊，或設定為其他數字來控制預設摺疊層級
vim.opt.foldlevel = 99
-- 摺疊欄位，顯示摺疊符號
vim.opt.foldcolumn = "1"
-- 開檔時不自動啟用折疊
vim.opt.foldenable = false
-- 摺疊時保留高亮
vim.opt.foldtext = ""

-- Use Tree-sitter folding for Python files, focusing on class and function definitions
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function()
    vim.opt_local.foldmethod = 'expr'
    vim.opt_local.foldexpr = 'nvim_treesitter#foldexpr()'
  end,
})

require 'my_kickstart'
