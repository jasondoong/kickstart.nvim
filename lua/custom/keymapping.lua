local map = vim.keymap.set

map('n', '<leader>cs', require('custom.show_class_methods').show_classes_and_methods, { desc = 'Open filtered doucment symbols in Quickfix list' })


