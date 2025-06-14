-- 使用縮排作為摺疊方式
vim.opt.foldmethod = "indent"
-- 預設開啟所有摺疊，或設定為其他數字來控制預設摺疊層級
vim.opt.foldlevel = 99
-- 摺疊欄位，顯示摺疊符號
vim.opt.foldcolumn = "1"

if vim.g.vscode then
  vim.keymap.set("i", "jk", "<Esc>", { desc = "jk to escape" })
else
  require 'my_kickstart'
end
