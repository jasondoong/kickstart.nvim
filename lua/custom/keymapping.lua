local map = vim.keymap.set

-- Helper that finds (or creates) a terminal and sends a command to it
local function send_to_terminal(cmd)
  local wins = vim.api.nvim_tabpage_list_wins(0)
  local term_win
  for _, w in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(w)
    if vim.bo[buf].buftype == 'terminal' then
      term_win = w
    end
  end

  local current = vim.api.nvim_get_current_win()

  if not term_win then
    vim.cmd('botright split')
    vim.cmd('terminal')
    term_win = vim.api.nvim_get_current_win()
  end

  local buf = vim.api.nvim_win_get_buf(term_win)
  local ok, job_id = pcall(vim.api.nvim_buf_get_var, buf, 'terminal_job_id')
  if ok then
    vim.api.nvim_chan_send(job_id, cmd .. '\n')
  else
    vim.api.nvim_win_call(term_win, function()
      vim.fn.feedkeys(cmd .. '\n')
    end)
  end

  vim.api.nvim_set_current_win(current)
end

-------------------------------------------------------------------------------
-- <leader>tt ── 依游標位置，組合 pytest node-id 並送到終端
-------------------------------------------------------------------------------
local function pytest_ts()
  ---------------------------------------------------------------------------
  -- ❶ 取得游標所在的函式/類別名稱
  ---------------------------------------------------------------------------
  local bufnr = 0
  local path = vim.fn.expand('%:p')

  -- 解析當前 buffer 的 python tree
  local parser = vim.treesitter.get_parser(bufnr, 'python')
  parser:parse()

  local ts_utils = require('nvim-treesitter.ts_utils')
  local node = ts_utils.get_node_at_cursor()

  local func_name
  local class_name

  while node do
    local type = node:type()
    if not func_name and type == 'function_definition' then
      local name = node:field('name')[1]
      func_name = vim.treesitter.get_node_text(name, bufnr)
    elseif type == 'class_definition' then
      local name = node:field('name')[1]
      class_name = vim.treesitter.get_node_text(name, bufnr)
      break
    end
    node = node:parent()
  end

  ---------------------------------------------------------------------------
  -- ❷ 組合 pytest node-id：函式 > class > 檔案
  ---------------------------------------------------------------------------
  local nodeid
  if func_name then
    if class_name then
      nodeid = string.format('%s::%s::%s', path, class_name, func_name)
    else
      nodeid = string.format('%s::%s', path, func_name)
    end
  elseif class_name then
    nodeid = string.format('%s::%s', path, class_name)
  else
    nodeid = path                                           -- fallback：整檔
  end

  local cmd = ('pytest %s'):format(nodeid)

  ---------------------------------------------------------------------------
  -- ❸ 送進終端
  ---------------------------------------------------------------------------
  send_to_terminal(cmd)
end

vim.keymap.set('n', '<leader>tt', pytest_ts, { desc = 'Run nearest pytest in terminal' })

local function run_pytest_file()
  local file = vim.fn.expand('%:p')
  send_to_terminal('pytest ' .. vim.fn.fnameescape(file))
end

map('n', '<leader>tf', run_pytest_file, { desc = 'run tests in the file' })

-- terminal
-- map('n', '<leader>h', ':horizontal terminal<CR>', { desc = 'split horizontal terminal' })
-- map('n', '<leader>v', ':vertical terminal<CR>', { desc = 'split vertical terminal' })
map('n', '<leader>z', ':ToggleTerm name=default<CR>', { desc = 'toggle default terminal' })
map('t', 'zz', [[<C-\><C-n>]], { desc = 'to normal mode' })

local Terminal = require('toggleterm.terminal').Terminal
local lazygit = Terminal:new({ cmd = 'lazygit', hidden = true })

local function lazygit_toggle()
  lazygit:toggle()
end

map('n', '<leader>lg', lazygit_toggle, { desc = 'toggle lazygit' })

-- quickfix
map('n', '<leader>co', ':copen<CR>', { desc = 'open quickfix window' })
map('n', '<leader>cc', ':cclose<CR>', { desc = 'close quickfix window' })

-- copy the current buffer's file path to the clipboard
map('n', '<leader>yf', function()
  local path = vim.fn.expand('%:p')
  vim.fn.setreg('+', path)
  vim.notify('Copied path: ' .. path)
end, { desc = '[Y]ank current [F]ile path' })
