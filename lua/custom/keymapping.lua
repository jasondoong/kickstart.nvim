local map = vim.keymap.set

map('n', '<leader>cs', require('custom.show_class_methods').show_classes_and_methods, { desc = 'Open filtered doucment symbols in Quickfix list' })

-- test shortcuts
map('n', '<leader>ta', ':Neotest attach<CR>', { desc = 'Neotest attach' })
map('n', '<leader>tl', ':lua require("neotest").run.run_last()<CR>', { desc = 'run the last test' })
map('n', '<leader>tt', ':lua require("neotest").run.run()<CR>', { desc = 'run the nearest test' })
map('n', '<leader>to', ':lua require("neotest").output.open({ enter = true })<CR>', { desc = 'open test output window' })
map('n', '<leader>ts', ':lua require("neotest").summary.toggle()<CR>', { desc = 'open test summary window' })
map('n', '<leader>tf', ':lua require("neotest").run.run(vim.fn.expand("%"))<CR>', { desc = 'run tests in the file' })
map('n', '<leader>td', ':lua require("neotest").run.run({stratege = "dap"})<CR>', { desc = 'run dap on nearest test' })

-- debug shortcuts
map("n", "<leader>dr", ':lua require("dap-python").test_method()<CR>', { desc = 'Debug: run nearest.' })


-- terminal
map("n", "<leader>h", ':horizontal terminal<CR>', { desc = 'split horizontal terminal' })
map("n", "<leader>v", ':vertical terminal<CR>', { desc = 'split vertical terminal' })


-- quickfix
map("n", "<leader>co", ':copen<CR>', { desc = 'open quickfix window' })
map("n", "<leader>cc", ':cclose<CR>', { desc = 'close quickfix window' })
