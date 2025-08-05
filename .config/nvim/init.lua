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
if not vim.g.vscode then
  require('mini.diff').setup({})
end
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

if vim.g.vscode then
  vim.keymap.set('n', 'cd', function()
    require('vscode').action('editor.action.rename')
  end)

  vim.keymap.set('n', 'gD', function()
    require('vscode').action('workbench.action.splitEditor')
    require('vscode').action('editor.action.goToDeclaration')
  end)

  vim.keymap.set('n', 'g/', function()
    require('vscode').action('workbench.action.findInFiles', { args = { query = vim.fn.expand('<cword>') } })
  end)

  vim.keymap.set('n', 'gs', function()
    require('vscode').action('editor.action.referenceSearch.trigger', { args = { query = vim.fn.expand('<cword>') } })
  end)

  vim.keymap.set('n', 'g]', function()
    require('vscode').action('editor.action.marker.next')
  end)

  vim.keymap.set('n', 'g[', function()
    require('vscode').action('editor.action.marker.prev')
  end)

  vim.keymap.set('n', 'g.', function()
    require('vscode').action('editor.action.quickFix')
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
  ensure_installed = { "astro", "markdown", "markdown_inline", "ledger", "lua", "typescript", "tsx" },
  -- Use treesitter highlighting
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true
  },
}


require 'nvim-treesitter.configs'.setup {
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["ai"] = "@conditional.outer",
        ["ii"] = "@conditional.inner",
        ["al"] = "@loop.outer",
        ["il"] = "@loop.inner",
        ["as"] = "@assignment.outer",
        ["is"] = "@assignment.inner",
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
        ["]f"] = "@function.outer",
        ["]c"] = "@class.outer",
        ["]i"] = "@conditional.outer",
        ["]l"] = "@loop.outer",
      },
      goto_next_end = {
        ["]F"] = "@function.outer",
        ["]C"] = "@class.outer",
        ["]I"] = "@conditional.outer",
        ["]L"] = "@loop.outer",
      },
      goto_previous_start = {
        ["[f"] = "@function.outer",
        ["[c"] = "@class.outer",
        ["[i"] = "@conditional.outer",
        ["[l"] = "@loop.outer",
      },
      goto_previous_end = {
        ["[F"] = "@function.outer",
        ["[C"] = "@class.outer",
        ["[I"] = "@conditional.outer",
        ["[L"] = "@loop.outer",
      },
    }
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

  vim.keymap.set('i', '<Tab>', [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
  vim.keymap.set('i', '<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })
end
