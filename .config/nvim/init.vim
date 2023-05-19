" Set up vim-plug plugins
" :PlugInstall to install
call plug#begin()
" gc to comment things out
Plug 'tpope/vim-commentary'
" New actions for surroundings like parentheses and brackets
Plug 'tpope/vim-surround'
" Camel-case and snake-case motions with \w
Plug 'bkad/CamelCaseMotion'
" More text object targets
Plug 'wellle/targets.vim'
" git integration
Plug 'tpope/vim-fugitive'

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
  set number

  " Don't force me to save files before opening a new one
  set hidden

  " Set up ayu color scheme
  set termguicolors
  let ayucolor="dark"
  colorscheme ayu
endif
