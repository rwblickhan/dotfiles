local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin')
Plug('tpope/vim-repeat')
Plug('tpope/vim-speeddating')
Plug('bkad/CamelCaseMotion')
Plug('machakann/vim-swap')
Plug('tadmccorkle/markdown.nvim')
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
Plug('Shatur/neovim-ayu')
Plug('junegunn/fzf')
Plug('junegunn/fzf.vim')
Plug('echasnovski/mini.nvim')
vim.call('plug#end')

require('mini.basics').setup()
require('mini.ai').setup({})
require('mini.comment').setup({})
require('mini.completion').setup({})
require('mini.diff').setup({})
require('mini.git').setup({})
require('mini.pairs').setup()
require('mini.jump').setup()
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
vim.opt.shiftwidth = 2
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
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 150 })
  end,
})

require('nvim-treesitter.configs').setup {
  ensure_installed = { "markdown", "markdown_inline", "ledger", "lua" },
  -- Use treesitter highlighting
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true
  },
  -- Use markdown.nvim 
  markdown = {
    enable = true,
    inline_surround = {
      emphasis = {
        txt = "_"
      }
    },
    on_attach = function(bufnr)
      local function toggle(key)
        return "<Esc>gv<Cmd>lua require'markdown.inline'"
          .. ".toggle_emphasis_visual'" .. key .. "'<CR>"
      end

      local map = vim.keymap.set
      local opts = { buffer = bufnr }
      map({ 'n', 'i' }, '<M-o>', '<Cmd>MDListItemBelow<CR>', opts)
      map({ 'n', 'i' }, '<M-O>', '<Cmd>MDListItemAbove<CR>', opts)
      map('n', '<M-c>', '<Cmd>MDTaskToggle<CR>', opts)
      map('x', '<M-c>', ':MDTaskToggle<CR>', opts)
      map("x", "<C-b>", toggle("b"), { buffer = bufnr })
      map("x", "<C-i>", toggle("i"), { buffer = bufnr })
    end,
  }
}

-- Use ayu dark
require('ayu').setup({
  mirage = false,
  terminal = true,
  overrides = {},
})
require('ayu').colorscheme()
