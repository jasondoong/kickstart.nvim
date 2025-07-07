local map = vim.keymap.set

-- cache the terminal buffer used for running pytest and last command
local pytest_term_bufnr
local last_pytest_cmd

-- Helper that finds (or creates) a terminal and sends a command to it
local function send_to_terminal(cmd)
  last_pytest_cmd = cmd

  local current = vim.api.nvim_get_current_win()
  local term_win

  if pytest_term_bufnr and vim.api.nvim_buf_is_valid(pytest_term_bufnr) then
    -- try to find an existing window displaying the terminal
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_get_buf(w) == pytest_term_bufnr then
        term_win = w
        break
      end
    end
  end

  if not term_win then
    vim.cmd('botright split')
    term_win = vim.api.nvim_get_current_win()
    if pytest_term_bufnr and vim.api.nvim_buf_is_valid(pytest_term_bufnr) then
      vim.api.nvim_win_set_buf(term_win, pytest_term_bufnr)
    else
      vim.cmd('terminal')
      pytest_term_bufnr = vim.api.nvim_win_get_buf(term_win)
    end
  end

  local buf = pytest_term_bufnr
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

local function run_last_pytest()
  if last_pytest_cmd then
    send_to_terminal(last_pytest_cmd)
  else
    vim.notify('No pytest command has been run yet', vim.log.levels.WARN)
  end
end

local function hide_pytest_terminal()
  if not pytest_term_bufnr or not vim.api.nvim_buf_is_valid(pytest_term_bufnr) then
    return
  end
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(w) == pytest_term_bufnr then
      vim.api.nvim_win_hide(w)
      break
    end
  end
end

map('n', '<leader>tl', run_last_pytest, { desc = 'rerun last pytest command' })
map('n', '<leader>th', hide_pytest_terminal, { desc = 'hide pytest terminal' })

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
