local M = {}

-- Setup Neo-tree views in a remote Kitty window
function M.setup()
  -- Only proceed when running as a remote UI
  if #vim.api.nvim_list_uis() <= 1 then
    return
  end

  vim.cmd('tabnew')
  vim.cmd('Neotree filesystem reveal left')
  vim.cmd('wincmd o')
  vim.cmd('Neotree document_symbols reveal right')
end

return M
