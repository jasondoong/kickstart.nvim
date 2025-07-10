-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  { 'sitiom/nvim-numbertoggle' },
  { 'github/copilot.vim' },
  { 'akinsho/toggleterm.nvim', version = "*",
    opts = {
      direction = 'float',
      float_opts = {
        width = math.floor(vim.o.columns * 0.9),
        height = math.floor(vim.o.lines * 0.9),
      }
    },
  },
  {
      "knubie/vim-kitty-navigator",
      build = "cp ./*.py ~/.config/kitty/",
  },
  {
    'stevearc/aerial.nvim',
    opts = {},
    config = function(_, opts)
      require('aerial').setup(opts)
    end,
  },
}
