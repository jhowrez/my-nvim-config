return {
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp',
      'neovim/nvim-lspconfig',
      'SirVer/ultisnips',
      'onsails/lspkind.nvim',
      'quangnguyen30192/cmp-nvim-ultisnips',
    },
    config = function()
      local cmp = require 'cmp'
      cmp.setup {
        snippet = {
          expand = function(args)
            vim.fn['UltiSnips#Anon'](args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm { select = true }, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        },
        sources = cmp.config.sources({ { name = 'nvim_lsp' }, { name = 'ultisnips' } }, { { name = 'buffer' } }),
      }
      local lspkind = require 'lspkind'
      cmp.setup {
        formatting = {
          format = lspkind.cmp_format {
            mode = 'symbol_text',
            maxwidth = 50,

            before = function(entry, vim_item)
              return vim_item
            end,
          },
        },
      }
    end,
  },
}
