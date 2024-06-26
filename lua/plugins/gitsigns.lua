return {
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup()
    end,
  },
  {
    'radyz/telescope-gitsigns',
    dependencies = {
      'lewis6991/gitsigns.nvim',
      'nvim-telescope/telescope.nvim',
      config = function()
        require('telescope').load_extension 'git_signs'
      end,
    },
  },
}
