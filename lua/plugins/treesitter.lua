return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
    local tsconfig = require 'nvim-treesitter.configs'
    tsconfig.setup {
      ensure_installed = {
        'lua',
        'go',
        'gosum',
        'gomod',
        'gowork',
        'vimdoc',
        'yaml',
        'json',
        'gitignore',
        'dockerfile',
      },
      highlight = { enable = true },
      indent = { enable = true },
    }
  end,
}
