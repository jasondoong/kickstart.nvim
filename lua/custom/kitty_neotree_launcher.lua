local M = {}

---Launch a kitty window showing only Neo-tree views
function M.launch()
  local server = vim.v.servername

  -- Start a unique server if none is running
  if server == '' then
    server = string.format('/tmp/nvim-%d.sock', vim.fn.getpid())
    vim.fn.serverstart(server)
  end

  local config = vim.fn.stdpath('config') .. '/neotree_only.lua'

  local cmd = {
    'kitty', '@', 'launch', '--type=window', '--title', 'Neo-tree',
    'nvim', '--server', server, '--remote-ui', '-u', config,
  }
  vim.fn.jobstart(cmd, { detach = true })
end

return M
