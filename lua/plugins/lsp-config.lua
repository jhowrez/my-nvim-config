return {
  {
    'williamboman/mason.nvim',

    dependencies = {
      'jay-babu/mason-nvim-dap.nvim',
    },
    config = function()
      require('mason').setup()
      require('mason-nvim-dap').setup {
        ensure_installed = {
          'codelldb',
        },
      }
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    config = function()
      require('mason-lspconfig').setup {
        ensure_installed = {
          'lua_ls',
          'gopls',
          'cmake',
          'clangd',
        },
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
    dependencies = {
      'ray-x/lsp_signature.nvim',
      'rcarriga/nvim-dap-ui',
    },
    config = function()
      local lspconfig = require 'lspconfig'
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      lspconfig.lua_ls.setup {}

      lspconfig.clangd.setup {
        capabilities = capabilities,
        on_attach = function()
          require('dapui').setup()
          local dap, dapui = require 'dap', require 'dapui'
          dap.listeners.before.attach.dapui_config = function()
            dapui.open()
          end
          dap.listeners.before.launch.dapui_config = function()
            dapui.open()
          end
          dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
          end
          dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
          end
          local mason_registry = require 'mason-registry'
          local codelldb_root = mason_registry.get_package('codelldb'):get_install_path() .. '/extension/'
          local codelldb_path = codelldb_root .. 'adapter/codelldb'
          local liblldb_path = codelldb_root .. 'lldb/lib/liblldb.so'
          dap.adapters.codelldb = {
            type = 'server',
            port = '${port}',
            host = '127.0.0.1',
            executable = {
              command = codelldb_path,
              args = { '--liblldb', liblldb_path, '--port', '${port}' },
            },
          }
          vim.o.updatetime = 250
          vim.diagnostic.config { virtual_text = false }
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
      }

      lspconfig.cmake.setup {}

      local caps = vim.tbl_deep_extend(
        'force',
        vim.lsp.protocol.make_client_capabilities(),
        require('cmp_nvim_lsp').default_capabilities(),
        -- File watching is disabled by default for neovim.
        -- See: https://github.com/neovim/neovim/pull/22405
        { workspace = { didChangeWatchedFiles = { dynamicRegistration = true } } }
      )
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, {})
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
      vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = 'rounded',
      })
      require('lsp_signature').setup {
        bind = true, -- This is mandatory, otherwise border config won't get registered.
        handler_opts = {
          border = 'rounded',
        },
      }
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
  {
    'Civitasv/cmake-tools.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'akinsho/toggleterm.nvim',
      'stevearc/overseer.nvim',
    },
    config = function()
      local osys = require 'cmake-tools.osys'
      require('cmake-tools').setup {
        cmake_command = 'cmake', -- this is used to specify cmake command path
        ctest_command = 'ctest', -- this is used to specify ctest command path
        cmake_use_preset = true,
        cmake_regenerate_on_save = true, -- auto generate when save CMakeLists.txt
        cmake_generate_options = {
          '-DCMAKE_EXPORT_COMPILE_COMMANDS=1',
          '-G Ninja',
        }, -- this will be passed when invoke `CMakeGenerate`
        cmake_build_options = {}, -- this will be passed when invoke `CMakeBuild`
        -- support macro expansion:
        --       ${kit}
        --       ${kitGenerator}
        --       ${variant:xx}
        cmake_build_directory = function()
          if osys.iswin32 then
            return 'out\\${variant:buildType}'
          end
          return 'out/${variant:buildType}'
        end, -- this is used to specify generate directory for cmake, allows macro expansion, can be a string or a function returning the string, relative to cwd.
        cmake_soft_link_compile_commands = true, -- this will automatically make a soft link from compile commands file to project root dir
        cmake_compile_commands_from_lsp = false, -- this will automatically set compile commands file location using lsp, to use it, please set `cmake_soft_link_compile_commands` to false
        cmake_kits_path = nil, -- this is used to specify global cmake kits path, see CMakeKits for detailed usage
        cmake_variants_message = {
          short = { show = true }, -- whether to show short message
          long = { show = true, max_length = 40 }, -- whether to show long message
        },
        cmake_dap_configuration = { -- debug settings for cmake
          name = 'cpp',
          type = 'codelldb',
          request = 'launch',
          stopOnEntry = false,
          runInTerminal = true,
          console = 'integratedTerminal',
        },
        cmake_executor = { -- executor to use
          name = 'quickfix', -- name of the executor
          opts = {}, -- the options the executor will get, possible values depend on the executor type. See `default_opts` for possible values.
          default_opts = { -- a list of default and possible values for executors
            quickfix = {
              show = 'always', -- "always", "only_on_error"
              position = 'belowright', -- "vertical", "horizontal", "leftabove", "aboveleft", "rightbelow", "belowright", "topleft", "botright", use `:h vertical` for example to see help on them
              size = 10,
              encoding = 'utf-8', -- if encoding is not "utf-8", it will be converted to "utf-8" using `vim.fn.iconv`
              auto_close_when_success = true, -- typically, you can use it with the "always" option; it will auto-close the quickfix buffer if the execution is successful.
            },
            toggleterm = {
              direction = 'float', -- 'vertical' | 'horizontal' | 'tab' | 'float'
              close_on_exit = false, -- whether close the terminal when exit
              auto_scroll = true, -- whether auto scroll to the bottom
              singleton = true, -- single instance, autocloses the opened one, if present
            },
            overseer = {
              new_task_opts = {
                strategy = {
                  'toggleterm',
                  direction = 'horizontal',
                  autos_croll = true,
                  quit_on_exit = 'success',
                },
              }, -- options to pass into the `overseer.new_task` command
              on_new_task = function(task)
                require('overseer').open { enter = false, direction = 'right' }
              end, -- a function that gets overseer.Task when it is created, before calling `task:start`
            },
            terminal = {
              name = 'Main Terminal',
              prefix_name = '[CMakeTools]: ', -- This must be included and must be unique, otherwise the terminals will not work. Do not use a simple spacebar " ", or any generic name
              split_direction = 'horizontal', -- "horizontal", "vertical"
              split_size = 11,

              -- Window handling
              single_terminal_per_instance = true, -- Single viewport, multiple windows
              single_terminal_per_tab = true, -- Single viewport per tab
              keep_terminal_static_location = true, -- Static location of the viewport if avialable

              -- Running Tasks
              start_insert = false, -- If you want to enter terminal with :startinsert upon using :CMakeRun
              focus = false, -- Focus on terminal when cmake task is launched.
              do_not_add_newline = false, -- Do not hit enter on the command inserted when using :CMakeRun, allowing a chance to review or modify the command before hitting enter.
            }, -- terminal executor uses the values in cmake_terminal
          },
        },
        cmake_runner = { -- runner to use
          name = 'terminal', -- name of the runner
          opts = {}, -- the options the runner will get, possible values depend on the runner type. See `default_opts` for possible values.
          default_opts = { -- a list of default and possible values for runners
            quickfix = {
              show = 'always', -- "always", "only_on_error"
              position = 'belowright', -- "bottom", "top"
              size = 10,
              encoding = 'utf-8',
              auto_close_when_success = true, -- typically, you can use it with the "always" option; it will auto-close the quickfix buffer if the execution is successful.
            },
            toggleterm = {
              direction = 'float', -- 'vertical' | 'horizontal' | 'tab' | 'float'
              close_on_exit = false, -- whether close the terminal when exit
              auto_scroll = true, -- whether auto scroll to the bottom
              singleton = true, -- single instance, autocloses the opened one, if present
            },
            overseer = {
              new_task_opts = {
                strategy = {
                  'toggleterm',
                  direction = 'horizontal',
                  autos_croll = true,
                  quit_on_exit = 'success',
                },
              }, -- options to pass into the `overseer.new_task` command
              on_new_task = function(task) end, -- a function that gets overseer.Task when it is created, before calling `task:start`
            },
            terminal = {
              name = 'Main Terminal',
              prefix_name = '[CMakeTools]: ', -- This must be included and must be unique, otherwise the terminals will not work. Do not use a simple spacebar " ", or any generic name
              split_direction = 'horizontal', -- "horizontal", "vertical"
              split_size = 11,

              -- Window handling
              single_terminal_per_instance = true, -- Single viewport, multiple windows
              single_terminal_per_tab = true, -- Single viewport per tab
              keep_terminal_static_location = true, -- Static location of the viewport if avialable

              -- Running Tasks
              start_insert = false, -- If you want to enter terminal with :startinsert upon using :CMakeRun
              focus = false, -- Focus on terminal when cmake task is launched.
              do_not_add_newline = false, -- Do not hit enter on the command inserted when using :CMakeRun, allowing a chance to review or modify the command before hitting enter.
            },
          },
        },
        cmake_notifications = {
          runner = { enabled = true },
          executor = { enabled = true },
          spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }, -- icons used for progress display
          refresh_rate_ms = 100, -- how often to iterate icons
        },
        cmake_virtual_text_support = true, -- Show the target related to current file using virtual text (at right corner)
      }
    end,
  },
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
    },
  },
  { 'folke/neodev.nvim', opts = {} },
  { 'akinsho/toggleterm.nvim', version = '*', config = true },
  {
    'stevearc/overseer.nvim',
    opts = {},
  },
}
