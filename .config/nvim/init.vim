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
Plug 'neoclide/coc-json', {'do': 'yarn install --frozen-lockfile'}
Plug 'fannheyward/coc-rust-analyzer', {'do': 'yarn install --frozen-lockfile'}
Plug 'fannheyward/coc-deno', {'do': 'yarn install --frozen-lockfile'}
" Dependency for null-ls
Plug 'nvim-lua/plenary.nvim'
" Bracket auto-pairing
Plug 'jiangmiao/auto-pairs'
" Syntax highlighting for just
Plug 'NoahTheDuke/vim-just'
" fzf vim integration
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
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

" Show syntax highlighting by default
syntax on

" Show line numbers by default
set number

" Don't force me to save files before opening a new one
set hidden

" Set up ayu color scheme
set termguicolors
let ayucolor="dark"
colorscheme ayu

" <leader>o to open fzf
noremap <silent> <Leader>o :FZF<CR>
" <leader>f to open fzf rg mode
noremap <silent> <Leader>f :Rg<CR>
" Don't match titles in fzf rg mode
command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)

" Go-to-definition code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

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
