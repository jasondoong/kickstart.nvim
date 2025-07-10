local M = {}

-- Launch a kitty window running the current Neovim instance
function M.launch()
  -- Ensure server is running
  if vim.v.servername == '' then
    vim.fn.serverstart('/tmp/nvim-main.sock')
  end

  -- Command to run in the new kitty window
  local cmd = {
    'kitty', '@', 'launch', '--type=window',
    'nvim', '--server', '/tmp/nvim-main.sock', '--remote-ui',
    '+lua require("custom.kitty_neotree").setup()'
  }
  vim.fn.jobstart(cmd, { detach = true })
end

-- Prepare the neo-tree views in this UI
function M.setup()
  vim.cmd('tabnew')
  vim.cmd('Neotree filesystem reveal left')
  vim.cmd('wincmd o')
  vim.cmd('Neotree document_symbols reveal right')
end

return M
