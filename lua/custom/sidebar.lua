local M = {}

function M.open()
  -- Open Neo-tree on the left
  vim.cmd('Neotree filesystem reveal left')
  local neo_win = vim.api.nvim_get_current_win()

  -- Split the Neo-tree window horizontally for Aerial
  vim.cmd('split')
  local aerial_win = vim.api.nvim_get_current_win()

  -- Open Aerial in the bottom split
  require('aerial').open({ direction = 'left', focus = false })

  -- Resize the splits: more space for Neo-tree (60%)
  local total = vim.api.nvim_win_get_height(neo_win) + vim.api.nvim_win_get_height(aerial_win)
  local neo_h = math.floor(total * 0.6)
  vim.api.nvim_win_set_height(neo_win, neo_h)
  vim.api.nvim_win_set_height(aerial_win, total - neo_h)

  -- Move focus back to the main editor window
  vim.cmd('wincmd l')
end

return M

