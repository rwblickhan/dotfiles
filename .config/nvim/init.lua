local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin')
Plug('tpope/vim-surround')
Plug('tpope/vim-repeat')
Plug('tpope/vim-speeddating')
Plug('tpope/vim-fugitive')
Plug('bkad/CamelCaseMotion')
Plug('machakann/vim-swap')
Plug('tadmccorkle/markdown.nvim')
Plug('christoomey/vim-tmux-navigator')
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
Plug('Shatur/neovim-ayu')
Plug('junegunn/fzf', { ['do'] = 'fzf#install()'  })
Plug('junegunn/fzf.vim')
Plug('echasnovski/mini.nvim')
vim.call('plug#end')

require('mini.basics').setup()
require('mini.ai').setup({})
require('mini.comment').setup({})
require('mini.completion').setup({})
require('mini.pairs').setup()
require('mini.jump').setup()

vim.keymap.set('n', 'H', '^', { noremap = true })
vim.keymap.set('n', 'L', '$', { noremap = true })
vim.keymap.set('v', 'H', '^', { noremap = true })
vim.keymap.set('v', 'L', '$', { noremap = true })
vim.keymap.set('i', '<Tab>',   [[pumvisible() ? "\<C-n>" : "\<Tab>"]],   { expr = true })
vim.keymap.set('i', '<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })

-- Use \ as leader
vim.g.mapleader = '\\'
-- Use /g by default in regex substitution
vim.opt.gdefault = true
-- Use 2 spaces for tabs
vim.opt.tabstop = 2
vim.opt.expandtab = true
-- Show relative line numbers
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
  ensure_installed = { "markdown", "markdown_inline", "ledger" },
  -- Use treesitter highlighting
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  -- Use markdown.nvim 
  markdown = {
    enable = true
  }
}

-- Use ayu dark
require('ayu').setup({
  mirage = false,
  terminal = true,
  overrides = {},
})
require('ayu').colorscheme()
