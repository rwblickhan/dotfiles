local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin')
Plug('tpope/vim-sensible')
Plug('tpope/vim-commentary')
Plug('tpope/vim-surround')
Plug('tpope/vim-repeat')
Plug('tpope/vim-speeddating')
Plug('bkad/CamelCaseMotion')
Plug('machakann/vim-swap')
Plug('wellle/targets.vim')
Plug('christoomey/vim-tmux-navigator')
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
Plug('Shatur/neovim-ayu')
Plug('echasnovski/mini.nvim')
vim.call('plug#end')

vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')
vim.keymap.set('n', 'H', '^', { noremap = true })
vim.keymap.set('n', 'L', '$', { noremap = true })
vim.keymap.set('v', 'H', '^', { noremap = true })
vim.keymap.set('v', 'L', '$', { noremap = true })
vim.keymap.set('i', '<Tab>',   [[pumvisible() ? "\<C-n>" : "\<Tab>"]],   { expr = true })
vim.keymap.set('i', '<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })

-- Use /g by default in regex substitution
vim.opt.gdefault = true
-- Use smarter regex case matching
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- Use 2 spaces for tabs
vim.opt.tabstop = 2
vim.opt.expandtab = true
-- Show relative line numbers
vim.opt.number = true
vim.opt.relativenumber = true
-- Use system clipboard
vim.opt.clipboard:append('unnamedplus')
-- Use \ as CamelCaseMotion hotkey
vim.g.camelcasemotion_key = '<leader>'

-- Highlight on yank 
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 })
  end,
})

require('nvim-treesitter.configs').setup {
  -- Use treesitter highlighting
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

require('mini.completion').setup({})
require('mini.pairs').setup()
require('mini.jump').setup()

-- Use ayu dark
require('ayu').setup({
  mirage = false,
  terminal = true,
  overrides = {},
})
require('ayu').colorscheme()
