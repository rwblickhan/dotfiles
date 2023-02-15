" Set up vim-plug plugins
" :PlugInstall to install
call plug#begin()
" Ayu theme
Plug 'ayu-theme/ayu-vim'
" Basic LSP configurations
Plug 'neovim/nvim-lspconfig'
" CoC autocompletion
" Remember to :CocInstall the appropriate languages and coc-snippets!
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" surround.vim
Plug 'tpope/vim-surround'
" Bracket auto-pairing
Plug 'jiangmiao/auto-pairs'
" Syntax highlighting for just
Plug 'NoahTheDuke/vim-just'
" tmux integration
Plug 'christoomey/vim-tmux-navigator'
" hledger integration
Plug 'ledger/vim-ledger'
call plug#end()

" Navigate up and down visual lines instead of logical ones
nmap j gj
nmap k gk

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

" Use system clipboard instead of * and + registers
set clipboard+=unnamedplus

" Select autocomplete on tab like VS Code
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'
