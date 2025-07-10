local M = {}

-- Launch a kitty window connected to the current Neovim instance
function M.launch()
  local server = vim.v.servername

  -- Start a unique server if none is running
  if server == '' then
    server = string.format('/tmp/nvim-%d.sock', vim.fn.getpid())
    vim.fn.serverstart(server)
  end

  local cmd = {
    'kitty', '@', 'launch', '--type=window',
    'nvim', '--server', server, '--remote-ui',
    '+lua require("custom.kitty_neotree_setup").setup()'
  }
  vim.fn.jobstart(cmd, { detach = true })
end

return M
