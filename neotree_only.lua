vim.o.loadplugins = false

vim.defer_fn(function()
  vim.cmd('Neotree filesystem reveal left')
  vim.cmd('wincmd o')
  vim.cmd('Neotree document_symbols reveal right')
end, 100)
