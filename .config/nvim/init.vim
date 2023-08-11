" Set up vim-plug plugins
" :PlugInstall to install
call plug#begin()
" Good ol' vim-sensible
Plug 'tpope/vim-sensible'
" gc to comment things out
Plug 'tpope/vim-commentary'
" New actions for surroundings like parentheses and brackets
Plug 'tpope/vim-surround'
" Camel-case and snake-case motions with \w
Plug 'bkad/CamelCaseMotion'
" Fix . for other plugins like vim-surround
Plug 'tpope/vim-repeat'
" Fix <C-a> and <C-x> for dates
Plug 'tpope/vim-speeddating'
" g< and g> to swap parameter arguments around
Plug 'machakann/vim-swap'
" s + 2 characters to jump anywhere
Plug 'justinmk/vim-sneak'

if !exists('g:vscode')
    " Only install these outside of VS Code
    " Ayu theme
    Plug 'ayu-theme/ayu-vim'
    " Basic LSP configurations
    Plug 'neovim/nvim-lspconfig'
    " Autocomplete with tab
    Plug 'ervandew/supertab'
    " tmux integration
    Plug 'christoomey/vim-tmux-navigator'
    " Syntax highlighting for just
    Plug 'NoahTheDuke/vim-just'
    " Syntax highlighting for hledger
    Plug 'ledger/vim-ledger'
endif
call plug#end()

" Use smart capitalization when searching
set ignorecase
set smartcase

" Use system clipboard instead of * and + registers
set clipboard+=unnamedplus

" Navigate up and down visual lines instead of logical ones
nmap j gj
nmap k gk

" Use \ for CamelCaseMotion
let g:camelcasemotion_key = '<leader>'

" https://github.com/vscode-neovim/vscode-neovim/issues/856
augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank { higroup="IncSearch", timeout=250 }
augroup END

if !exists('g:vscode')
  " Handle tabs correctly (== by turning them into spaces 🙂)
  filetype plugin indent on
  set tabstop=4
  set shiftwidth=4
  set expandtab

  " Show line numbers by default
  set number relativenumber

  " Don't force me to save files before opening a new one
  set hidden

  " Set up ayu color scheme
  set termguicolors
  let ayucolor="dark"
  colorscheme ayu
endif
