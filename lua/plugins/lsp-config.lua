return {
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    config = function()
      require('mason-lspconfig').setup {
        ensure_installed = { 'lua_ls', 'gopls' },
      }
    end,
  },
  {
    'ray-x/lsp_signature.nvim',
    event = 'VeryLazy',
    opts = {},
    config = function(_, opts)
      require('lsp_signature').setup(opts)
    end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'ray-x/lsp_signature.nvim' },
    config = function()
      local lspconfig = require 'lspconfig'
      lspconfig.lua_ls.setup {}

      require('lsp_signature').setup {
        bind = true, -- This is mandatory, otherwise border config won't get registered.
        handler_opts = {
          border = 'rounded',
        },
      }
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, {})
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
      vim.keymap.set({ 'n' }, '<C-k>', function()
        require('lsp_signature').toggle_float_win()
      end, { silent = true, noremap = true, desc = 'toggle signature' })
    end,
  },
  {
    'wesleimp/stylua.nvim',
    config = function()
      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = '*.lua',
        callback = function()
          require('stylua').format()
        end,
      })
    end,
  },
  {
    'fatih/vim-go',
    dependencies = {
      'SirVer/ultisnips',
      'quangnguyen30192/cmp-nvim-ultisnips',
      'hrsh7th/nvim-cmp',
      'onsails/lspkind.nvim',
    },
    build = ':GoInstallBinaries',
    config = function()
      local lspconfig = require 'lspconfig'
      local cmp = require 'cmp'
      local cmp_nvim_lsp = require 'cmp_nvim_lsp'
      local lspkind = require 'lspkind'

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
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'ultisnips' },
        }, {
          { name = 'buffer' },
        }),
      }

      -- cmp
      local capabilities = cmp_nvim_lsp.default_capabilities()
      local on_attach = function(client, bufnr)
        local format_sync_grp = vim.api.nvim_create_augroup('goimports', {})
        vim.api.nvim_create_autocmd('BufWritePre', {
          pattern = '*.go',
          callback = function()
            vim.cmd ':GoFmt'
          end,
          group = format_sync_grp,
        })

        vim.api.nvim_create_autocmd('FileType', {
          pattern = { 'go' },
          callback = function()
            vim.keymap.set('n', '<leader>sf', function()
              vim.cmd ':GoFillStruct'
            end)
          end,
        })
      end

      -- lsp config
      lspconfig.gopls.setup {
        capabilities = capabilities,
        on_attach = on_attach,
      }
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
  { 'SirVer/ultisnips' },
}
