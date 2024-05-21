-- Making my life more complicated Part 1.0

-- Global Mappings
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)
vim.keymap.set('n', '<leader>ee', function()
  vim.cmd ':Neotree toggle'
end)

-- Trouble
local trouble = require 'trouble'
vim.keymap.set('n', '<leader>xx', function()
  trouble.toggle()
end)

-- Neovim
local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>sn', function()
  builtin.find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch [N]eovim files' })

-- Golang
-- vim.cmd 'autocmd BufWritePre (InsertLeave?) <buffer> lua vim.lsp.buf.formatting_sync(nil,500)'
local format_sync_grp = vim.api.nvim_create_augroup('goimports', {})
vim.api.nvim_create_autocmd('BufWritePre', {
  group = format_sync_grp,
  pattern = '*.go',
  callback = function()
    require('go.format').goimports()
  end,
})
vim.api.nvim_create_autocmd('BufWritePost', {
  group = format_sync_grp,
  pattern = '*.go',
  callback = function()
    if not vim.wo.diff then
      local inlay = require 'go.inlay'
      inlay.disable_inlay_hints(true)
      inlay.set_inlay_hints()
    end
  end,
})

vim.api.nvim_create_autocmd('InsertLeave', {
  group = format_sync_grp,
  pattern = { '*.go' },
  callback = function()
    do
      return
    end
    vim.lsp.buf.format { async = false }
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'go' },
  callback = function()
    vim.keymap.set('n', '<leader>sf', function()
      vim.cmd ':GoFillStruct'
    end)
    vim.keymap.set('n', '<c-f>', function()
      require('go.format').goimports()
    end)
  end,
})
