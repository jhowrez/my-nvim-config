-- Making my life more complicated Part 1.0

-- Global Mappings
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)
vim.keymap.set('n', '<leader>ee', function()
  vim.cmd ':Neotree toggle'
end)

-- Golang
local format_sync_grp = vim.api.nvim_create_augroup('goimports', {})
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.go',
  callback = function()
    require('go.format').goimports()
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

-- Lua
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.lua',
  callback = function()
    require('stylua').format()
  end,
})
