local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin')
Plug('bkad/CamelCaseMotion')
Plug('echasnovski/mini.nvim')
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
Plug('nvim-treesitter/nvim-treesitter-textobjects')
Plug('tpope/vim-repeat')
Plug('tpope/vim-speeddating')
Plug('vim-scripts/twilight256.vim')
vim.call('plug#end')

require('mini.basics').setup()
require('mini.ai').setup({})
require('mini.comment').setup({})
require('mini.completion').setup({})
require('mini.diff').setup({})
require('mini.git').setup({})
require('mini.jump').setup()
require('mini.operators').setup()
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
}


require'nvim-treesitter.configs'.setup {
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",  -- around function
        ["if"] = "@function.inner",  -- inner function
        ["ac"] = "@class.outer",     -- around class
        ["ic"] = "@class.inner",     -- inner class
      },
      include_surrounding_whitespace = true,
    },
    swap = {
      enable = true,
      swap_next = {
        ["g>"] = "@parameter.inner",
      },
      swap_previous = {
        ["g<"] = "@parameter.inner",
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        ["]m"] = "@function.outer",
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
      },
      goto_next = {
        ["]d"] = "@conditional.outer",
      },
      goto_previous = {
        ["[d"] = "@conditional.outer",
      }
    },
  },
}

if not vim.g.vscode then
  -- Set the background to black
  vim.api.nvim_create_autocmd('ColorScheme', {
    callback = function()
      vim.api.nvim_set_hl(0, 'Normal', { bg = '#000000' })
    end
  })

  vim.cmd.colorscheme('twilight256')

  -- Highlight on yank 
  vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
      vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 150 })
    end,
  })

  vim.keymap.set('i', '<Tab>',   [[pumvisible() ? "\<C-n>" : "\<Tab>"]],   { expr = true })
  vim.keymap.set('i', '<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })
end
