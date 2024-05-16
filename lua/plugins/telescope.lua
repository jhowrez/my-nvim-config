return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.6',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require 'telescope.builtin'
      local utils = require 'telescope.utils'
      vim.keymap.set('n', '<leader>ff', function()
        builtin.find_files {}
      end, { desc = 'Find files in root' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
    end,
  },
  {
    'nvim-telescope/telescope-ui-select.nvim',
    config = function()
      local actions = require 'telescope.actions'
      require('telescope').setup {
        pickers = {
          buffers = {
            mappings = {
              i = {
                ['<c-d>'] = actions.delete_buffer + actions.move_to_top,
              },
            },
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown {},
          },
        },
      }
      require('telescope').load_extension 'ui-select'
    end,
  },
}
