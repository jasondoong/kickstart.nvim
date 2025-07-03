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
vim.keymap.set('n', '<leader>tt', function()
  ---------------------------------------------------------------------------
  -- ❶ 向上掃描：最近 test_ 函式；若無則檢查 Test class
  ---------------------------------------------------------------------------
  local buf        = 0                                  -- 目前 buffer
  local path       = vim.fn.expand('%:p')                -- 絕對檔名
  local cur_ln     = vim.fn.line('.') - 1                -- 0-based
  local getline    = vim.api.nvim_buf_get_lines

  local func_name, func_indent
  local class_name, class_indent

  for ln = cur_ln, 0, -1 do
    local text   = (getline(buf, ln, ln + 1, false)[1] or '')
    local indent = #text:match('^%s*')

    -------------------------------------------------------------------------
    -- 找最近的 def test_*  （允許前面有 async / 型別註解）
    -------------------------------------------------------------------------
    if not func_name then
      local fn = text:match('^%s*[%w%s]*def%s+(test[%w_]*)')
      if fn then
        func_name, func_indent = fn, indent
      end
    end

    -------------------------------------------------------------------------
    -- ◎ 已找到函式 → 往上找包住它的 Test class
    -------------------------------------------------------------------------
    if func_name and not class_name and indent < func_indent then
      local cls = text:match('^%s*class%s+([%w_]+)')
      if cls and cls:match('^Test') then
        class_name, class_indent = cls, indent
        break                                     -- 找到即可停止
      end
    end

    -------------------------------------------------------------------------
    -- ◎ 尚未找到函式 → 若此行就是 Test class，代表游標在 class 層
    -------------------------------------------------------------------------
    if not func_name and not class_name then
      local cls_top = text:match('^%s*class%s+([%w_]+)')
      if cls_top and cls_top:match('^Test') then
        class_name, class_indent = cls_top, indent
        break                                     -- 直接執行整個 class
      end
    end
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
end, { desc = 'Run nearest pytest via Kitty' })

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
