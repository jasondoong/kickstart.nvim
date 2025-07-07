local map = vim.keymap.set

local kitty_listen_on = os.getenv('KITTY_LISTEN_ON')

-- test shortcuts
map('n', '<leader>ta', ':Neotest attach<CR>', { desc = 'Neotest attach' })
-- map('n', '<leader>tl', ':lua require("neotest").run.run_last()<CR>', { desc = 'run the last test' })
-- ~/.config/nvim/init.lua or other keymap file
vim.keymap.set('n', '<leader>tl', function()
  if kitty_listen_on then
    local cmd = string.format(
      'silent !kitty @ --to %s send-text --match var:id=main_bottom "pytest --lf\\n"',
      kitty_listen_on
    )
    -- print(cmd)
    vim.cmd(cmd)
  else
    print("Kitty is not running or KITTY_LISTEN_ON is not set.")
  end
end, { desc = '[T]est [L]ast in runner pane' })

-- map('n', '<leader>tt', ':lua require("neotest").run.run()<CR>', { desc = 'run the nearest test' })
-------------------------------------------------------------------------------
-- <leader>tt ── 依游標位置，組合 pytest node-id 並送到 Kitty 指定 pane
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

  local cmd = ('pytest %s\n'):format(nodeid)

  ---------------------------------------------------------------------------
  -- ❸ 送進 Kitty 的 main_bottom pane
  ---------------------------------------------------------------------------
  local kitty_to = vim.g.kitty_listen_on or os.getenv('KITTY_LISTEN_ON')
  if not kitty_to or kitty_to == '' then
    vim.notify('Kitty 沒有啟動或 KITTY_LISTEN_ON 未設定', vim.log.levels.ERROR)
    return
  end

  local kitty_cmd = string.format(
    'kitty @ --to %s send-text --match var:id=main_bottom "%s"',
    kitty_to,
    cmd:gsub('"', '\\"')   -- escape 雙引號
  )
  vim.fn.system(kitty_cmd)
end

vim.keymap.set('n', '<leader>tt', pytest_ts, { desc = 'Run nearest pytest via Kitty' })

map('n', '<leader>to', ':lua require("neotest").output_panel.toggle()<CR>', { desc = 'open test output panel' })
map('n', '<leader>ts', ':lua require("neotest").summary.toggle()<CR>', { desc = 'open test summary window' })
map('n', '<leader>tf', ':lua require("neotest").run.run(vim.fn.expand("%"))<CR>', { desc = 'run tests in the file' })

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
