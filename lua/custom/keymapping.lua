local map = vim.keymap.set

map('n', '<leader>cs', require('custom.show_class_methods').show_classes_and_methods, { desc = 'Open filtered doucment symbols in Quickfix list' })

-- test shortcuts
map('n', '<leader>tr', ':lua require("neotest").run.run()<CR>', { desc = 'run the nearest test' })
map('n', '<leader>to', ':lua require("neotest").output.open({ enter = true })<CR>', { desc = 'open test output window' })
map('n', '<leader>ts', ':lua require("neotest").summary.toggle()<CR>', { desc = 'open test summary window' })
map('n', '<leader>tf', ':lua require("neotest").run.run(vim.fn.expand("%"))<CR>', { desc = 'open test summary window' })
map('n', '<leader>td', ':lua require("neotest").run.run({stratege = "dap"})<CR>', { desc = 'run dap on nearest test' })

