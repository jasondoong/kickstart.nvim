local map = vim.keymap.set

-- test shortcuts
map('n', '<leader>ta', ':Neotest attach<CR>', { desc = 'Neotest attach' })
map('n', '<leader>tl', ':lua require("neotest").run.run_last()<CR>', { desc = 'run the last test' })
-- map('n', '<leader>tt', ':lua require("neotest").run.run()<CR>', { desc = 'run the nearest test' })
map('n', '<leader>tt', function()
  require("neotest").run.run()
  vim.defer_fn(function()
    require("neotest").run.attach()
  end, 500) -- Delay of 500ms to wait for the test to start
end, { desc = 'Run the nearest test and attach' })
map('n', '<leader>to', ':lua require("neotest").output_panel.toggle()<CR>', { desc = 'open test output panel' })
map('n', '<leader>ts', ':lua require("neotest").summary.toggle()<CR>', { desc = 'open test summary window' })
map('n', '<leader>tf', ':lua require("neotest").run.run(vim.fn.expand("%"))<CR>', { desc = 'run tests in the file' })
map('n', '<leader>td', ':lua require("neotest").run.run({stratege = "dap"})<CR>', { desc = 'run dap on nearest test' })
-- debug shortcuts
map('n', '<leader>dr', ':lua require("dap-python").test_method()<CR>', { desc = 'Debug: run nearest.' })

-- terminal
-- map('n', '<leader>h', ':horizontal terminal<CR>', { desc = 'split horizontal terminal' })
-- map('n', '<leader>v', ':vertical terminal<CR>', { desc = 'split vertical terminal' })
map('n', '<leader>z', ':ToggleTerm name=default<CR>', { desc = 'toggle default terminal' })

local Terminal  = require('toggleterm.terminal').Terminal
local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })

function _lazygit_toggle()
  lazygit:toggle()
end

map("n", "<leader>lg", "<cmd>lua _lazygit_toggle()<CR>", { desc = 'toggle lazygit' })

-- quickfix
map('n', '<leader>co', ':copen<CR>', { desc = 'open quickfix window' })
map('n', '<leader>cc', ':cclose<CR>', { desc = 'close quico/fix window' })
