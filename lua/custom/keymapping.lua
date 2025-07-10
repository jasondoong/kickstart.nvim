local map = vim.keymap.set
local kitty_neotree = require('custom.kitty_neotree_launcher')

-------------------------------------------------------------------------------
-- Pytest integration
-------------------------------------------------------------------------------
-- Terminal buffer used for running pytest
local pytest_buf
-- The window that currently displays `pytest_buf`
local pytest_win
-- Track the last pytest command so it can be re-run
local last_pytest_cmd = 'pytest'

-- Helper that finds (or creates) a terminal and sends a command to it
-- Send a command to the pytest terminal.  If the terminal does not exist,
-- it will be created.  The last command is stored so that it can be
-- executed again with <leader>tl.
local function send_to_terminal(cmd)
  last_pytest_cmd = cmd

  if not pytest_buf or not vim.api.nvim_buf_is_valid(pytest_buf) then
    -- Create a new terminal buffer and window
    vim.cmd('botright split')
    vim.cmd('terminal')
    pytest_win = vim.api.nvim_get_current_win()
    pytest_buf = vim.api.nvim_get_current_buf()
  elseif not pytest_win or not vim.api.nvim_win_is_valid(pytest_win) then
    -- The buffer exists but the window was closed: re-open the window
    vim.cmd('botright split')
    pytest_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(pytest_win, pytest_buf)
  end

  local current = vim.api.nvim_get_current_win()

  -- Try sending directly to the running job if available
  local ok, job_id = pcall(vim.api.nvim_buf_get_var, pytest_buf, 'terminal_job_id')
  if ok then
    vim.api.nvim_chan_send(job_id, cmd .. '\n')
  else
    vim.api.nvim_win_call(pytest_win, function()
      vim.fn.feedkeys(cmd .. '\n')
    end)
  end

  vim.api.nvim_set_current_win(current)
end

-- Toggle the pytest terminal window without closing the buffer.  If the
-- window is already visible it will be hidden; if hidden it will be shown.
-- When no terminal exists yet it will be spawned using the last command.
local function toggle_pytest_terminal()
  if pytest_win and vim.api.nvim_win_is_valid(pytest_win) then
    vim.api.nvim_win_close(pytest_win, true)
    pytest_win = nil
  elseif pytest_buf and vim.api.nvim_buf_is_valid(pytest_buf) then
    vim.cmd('botright split')
    pytest_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(pytest_win, pytest_buf)
  else
    send_to_terminal(last_pytest_cmd)
  end
end

-- Run the most recently executed pytest command
local function run_last_pytest()
  send_to_terminal(last_pytest_cmd)
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
  -- Run pytest on the current file
  local file = vim.fn.expand('%:p')
  send_to_terminal('pytest ' .. vim.fn.fnameescape(file))
end

-- Key mappings for pytest workflow
map('n', '<leader>tf', run_pytest_file, { desc = 'run tests in the file' })
map('n', '<leader>tl', run_last_pytest, { desc = 'run latest pytest again' })
map('n', '<leader>to', toggle_pytest_terminal, { desc = 'toggle pytest output window' })

-- terminal
local split_term_buf
local split_term_win

local function toggle_horizontal_terminal()
  if split_term_win and vim.api.nvim_win_is_valid(split_term_win) then
    vim.api.nvim_win_close(split_term_win, true)
    split_term_win = nil
  elseif split_term_buf and vim.api.nvim_buf_is_valid(split_term_buf) then
    vim.cmd('botright split')
    split_term_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(split_term_win, split_term_buf)
  else
    vim.cmd('botright split')
    vim.cmd('terminal')
    split_term_win = vim.api.nvim_get_current_win()
    split_term_buf = vim.api.nvim_get_current_buf()
  end
end

map('n', '<leader>h', toggle_horizontal_terminal, { desc = 'toggle horizontal terminal' })
-- map('n', '<leader>v', ':vertical terminal<CR>', { desc = 'split vertical terminal' })
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

map('n', '<leader>ns', kitty_neotree.launch, { desc = 'neo-tree: files + symbols' })

-- copy the current buffer's file path to the clipboard
map('n', '<leader>yf', function()
  -- Use the path relative to the current working directory instead of the
  -- absolute path. This keeps the copied path shorter when working inside a
  -- project directory.
  local path = vim.fn.fnamemodify(vim.fn.expand('%:p'), ':.')
  vim.fn.setreg('+', path)
  vim.notify('Copied path: ' .. path)
end, { desc = '[Y]ank current [F]ile path' })
