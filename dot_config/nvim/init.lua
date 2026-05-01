local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin')
Plug('bkad/CamelCaseMotion')
Plug('nvim-mini/mini.nvim')
Plug('tpope/vim-repeat')
Plug('tpope/vim-speeddating')
vim.call('plug#end')

require('mini.basics').setup()
require('mini.ai').setup({})
require('mini.comment').setup({})
require('mini.git').setup({})
require('mini.jump').setup()
require('mini.jump2d').setup({
  mappings = { start_jumping = 'gw' },
})
require('mini.operators').setup({ replace = { prefix = "<leader>R" }})
require('mini.surround').setup({
  mappings = {
    add = 'ys',
    delete = 'ds',
    find = '',
    find_left = '',
    highlight = '',
    replace = 'cs',
    update_n_lines = '',
  },
  search_method = 'cover_or_next',
})

vim.keymap.set('n', 'j', 'gj', { noremap = true })
vim.keymap.set('n', 'k', 'gk', { noremap = true })
vim.keymap.set('n', 'gj', 'j', { noremap = true })
vim.keymap.set('n', 'gk', 'k', { noremap = true })
vim.keymap.set('n', 'H', '^', { noremap = true })
vim.keymap.set('n', 'L', '$', { noremap = true })
vim.keymap.set('v', 'H', '^', { noremap = true })
vim.keymap.set('v', 'L', '$', { noremap = true })

if vim.g.vscode then
  vim.keymap.set('n', '<leader>r', function()
    require('vscode').action('editor.action.rename')
  end)

  vim.keymap.set('n', '<leader>a', function()
    require('vscode').action('editor.action.quickFix')
  end)

  vim.keymap.set('n', 'g/', function()
    require('vscode').action('workbench.action.findInFiles', { args = { query = vim.fn.expand('<cword>') } })
  end)

  vim.keymap.set('n', 'gr', function()
    require('vscode').action('editor.action.referenceSearch.trigger', { args = { query = vim.fn.expand('<cword>') } })
  end)

  vim.keymap.set('n', ']d', function()
    require('vscode').action('editor.action.marker.next')
  end)

  vim.keymap.set('n', '[d', function()
    require('vscode').action('editor.action.marker.prev')
  end)

  vim.keymap.set('n', ']g', function()
    require('vscode').action('workbench.action.editor.nextChange')
  end)

  vim.keymap.set('n', '[g', function()
    require('vscode').action('workbench.action.editor.previousChange')
  end)

  vim.keymap.set('n', 'go', function()
    require('vscode').action('openInGitHub.openFile')
  end)

  vim.keymap.set('n', 'gy', function()
    require('vscode').action('editor.showCallHierarchy')
  end)

  vim.keymap.set('n', 'm', function()
    require('vscode').action('bookmarks.toggle')
  end)

  vim.keymap.set('n', '\'', function()
    require('vscode').action('bookmarks.list')
  end)

  vim.keymap.set('n', '"', function()
    require('vscode').action('bookmarks.listFromAllFiles')
  end)
end


-- Use \ as leader
vim.g.mapleader = '<space>'
-- Use /g by default in regex substitution
vim.opt.gdefault = true
-- Use 2 spaces for tabs
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
-- Show relative line numbers
vim.opt.relativenumber = true
-- Use system clipboard
vim.opt.clipboard:append('unnamedplus')
-- Use \ as CamelCaseMotion hotkey
vim.g.camelcasemotion_key = '\\'
