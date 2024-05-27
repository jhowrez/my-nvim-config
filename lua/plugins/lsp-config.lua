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
        ensure_installed = { 'lua_ls', 'gopls', 'clangd', 'nil_ls' },
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
      lspconfig.clangd.setup {}

      local caps = vim.tbl_deep_extend(
        'force',
        vim.lsp.protocol.make_client_capabilities(),
        require('cmp_nvim_lsp').default_capabilities(),
        -- File watching is disabled by default for neovim.
        -- See: https://github.com/neovim/neovim/pull/22405
        { workspace = { didChangeWatchedFiles = { dynamicRegistration = true } } }
      )
      lspconfig.nil_ls.setup {
        autostart = true,
        capacabilities = caps,
        settings = {
          ['nil'] = {
            testSetting = 42,
            formatting = {
              command = { 'nixpkgs-fmt' },
            },
          },
        },
      }
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, {})
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
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
    'ray-x/go.nvim',
    dependencies = { -- optional packages
      'ray-x/guihua.lua',
      'neovim/nvim-lspconfig',
      'nvim-treesitter/nvim-treesitter',
      'hrsh7th/nvim-cmp',
      'mfussenegger/nvim-dap',
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
      'ray-x/lsp_signature.nvim',
    },
    config = function()
      require('go').setup {
        lsp_cfg = true,
        goimports = 'gopls',
        gofmt = 'gofmt',
        lsp_on_attach = function(client, bufnr)
          vim.o.updatetime = 250
          vim.api.nvim_create_autocmd('CursorHold', {
            buffer = bufnr,
            callback = function()
              local opts = {
                focusable = false,
                close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
                border = 'rounded',
                source = 'always',
                prefix = ' ',
                scope = 'cursor',
              }
              vim.diagnostic.open_float(nil, opts)
            end,
          })
        end,
        dap_debug = true,
        fillstruct = 'gopls',
        trouble = false,
        lsp_codelens = true,
        diagnostic = {
          underline = true,
          signs = true,
          update_in_insert = true,
        },
        lsp_inlay_hints = {
          enable = true,
          style = 'eol',
        },
      }
      -- cmp
      local cfg = require('go.lsp').config()

      require('lspconfig').gopls.setup(cfg)

      require('lsp_signature').setup {
        bind = true, -- This is mandatory, otherwise border config won't get registered.
        handler_opts = {
          border = 'rounded',
        },
      }
    end,
    event = { 'CmdlineEnter' },
    ft = { 'go', 'gomod' },
    build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
  },
  { 'SirVer/ultisnips' },
}
