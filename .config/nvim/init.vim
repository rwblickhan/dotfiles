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
" More text object targets
Plug 'wellle/targets.vim'
" Fix . for other plugins like vim-surround
Plug 'tpope/vim-repeat'
" Fix <C-a> and <C-x> for dates
Plug 'tpope/vim-speeddating'
" g< and g> to swap parameter arguments around
Plug 'machakann/vim-swap'
" gJ to smart-join lines and gS to smart-split
Plug 'andrewradev/splitjoin.vim'
" ga to start alignment mode, then select an alignment
Plug 'junegunn/vim-easy-align'

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

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" https://github.com/vscode-neovim/vscode-neovim/issues/856
augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank { higroup="IncSearch", timeout=250 }
augroup END

" https://gist.github.com/PeterRincker/582ea9be24a69e6dd8e237eb877b8978
" :[range]SortGroup[!] [n|f|o|b|x] /{pattern}/
" e.g. :SortGroup /^header/
" e.g. :SortGroup n /^header/
" See :h :sort for details

function! s:sort_by_header(bang, pat) range
  let pat = a:pat
  let opts = ""
  if pat =~ '^\s*[nfxbo]\s'
    let opts = matchstr(pat, '^\s*\zs[nfxbo]')
    let pat = matchstr(pat, '^\s*[nfxbo]\s*\zs.*')
  endif
  let pat = substitute(pat, '^\s*', '', '')
  let pat = substitute(pat, '\s*$', '', '')
  let sep = '/'
  if len(pat) > 0 && pat[0] == matchstr(pat, '.$') && pat[0] =~ '\W'
    let [sep, pat] = [pat[0], pat[1:-2]]
  endif
  if pat == ''
    let pat = @/
  endif

  let ranges = []
  execute a:firstline . ',' . a:lastline . 'g' . sep . pat . sep . 'call add(ranges, line("."))'

  let converters = {
        \ 'n': {s-> str2nr(matchstr(s, '-\?\d\+.*'))},
        \ 'x': {s-> str2nr(matchstr(s, '-\?\%(0[xX]\)\?\x\+.*'), 16)},
        \ 'o': {s-> str2nr(matchstr(s, '-\?\%(0\)\?\x\+.*'), 8)},
        \ 'b': {s-> str2nr(matchstr(s, '-\?\%(0[bB]\)\?\x\+.*'), 2)},
        \ 'f': {s-> str2float(matchstr(s, '-\?\d\+.*'))},
        \ }
  let arr = []
  for i in range(len(ranges))
    let end = max([get(ranges, i+1, a:lastline+1) - 1, ranges[i]])
    let line = getline(ranges[i])
    let d = {}
    let d.key = call(get(converters, opts, {s->s}), [strpart(line, match(line, pat))])
    let d.group = getline(ranges[i], end)
    call add(arr, d)
  endfor
  call sort(arr, {a,b -> a.key == b.key ? 0 : (a.key < b.key ? -1 : 1)})
  if a:bang
    call reverse(arr)
  endif
  let lines = []
  call map(arr, 'extend(lines, v:val.group)')
  let start = max([a:firstline, get(ranges, 0, 0)])
  call setline(start, lines)
  call setpos("'[", start)
  call setpos("']", start+len(lines)-1)
endfunction
command! -range=% -bang -nargs=+ SortGroup <line1>,<line2>call <SID>sort_by_header(<bang>0, <q-args>)

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
