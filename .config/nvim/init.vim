" Set up vim-plug plugins
" :PlugInstall to install
call plug#begin()
" Palenight theme
Plug 'drewtempelmeyer/palenight.vim'
" Basic LSP configurations
Plug 'neovim/nvim-lspconfig'
" Dependencies for Trouble
Plug 'kyazdani42/nvim-web-devicons'
Plug 'folke/lsp-colors.nvim'
" A pretty LSP diagnostics menu
" :Trouble to pull it up
Plug 'folke/trouble.nvim'
" Dependency for null-ls
Plug 'nvim-lua/plenary.nvim'
" Hook non-LSP sources into neovim's LSP implementation
Plug 'jose-elias-alvarez/null-ls.nvim'
" Terraform support
Plug 'hashivim/vim-terraform'
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

" Set up palenight color scheme
set background=dark
colorscheme palenight
set termguicolors
let g:palenight_terminal_italics=1

lua << EOF
  -- Set :Format as an alias for LSP formatting
  vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting_sync()' ]]
  -- Set <leader>f as an alias for :Format
  vim.api.nvim_set_keymap("n", "<leader>f", ":Format<cr>", { noremap = true })

  require("trouble").setup {}
  require("null-ls").setup({
    sources = {
        require("null-ls").builtins.diagnostics.flake8,
        require("null-ls").builtins.diagnostics.hadolint,
        require("null-ls").builtins.diagnostics.markdownlint,
        require("null-ls").builtins.diagnostics.shellcheck,
        -- require("null-ls").builtins.diagnostics.swiftformat,
        require("null-ls").builtins.diagnostics.vale,
        require("null-ls").builtins.diagnostics.yamllint,
        require("null-ls").builtins.formatting.terraform_fmt
    },
  })
EOF
