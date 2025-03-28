if vim.g.vscode then
  vim.keymap.set("i", "jk", "<Esc>", { desc = "jk to escape" })
else
  require 'my_kickstart'
end
