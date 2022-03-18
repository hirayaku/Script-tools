set nocompatible
set encoding=utf-8
filetype off

call plug#begin()

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'majutsushi/tagbar'              "In-file navigation
Plug 'ludovicchabant/vim-gutentags'   "Better ctags manager
Plug 'preservim/nerdcommenter'        "Commenter
Plug 'preservim/nerdtree'             "File navigator
Plug 'vim-airline/vim-airline'        "Fancy status bar
Plug 'jeffkreeftmeijer/vim-numbertoggle' "Toggle relative/absolute nu
Plug 'tpope/vim-fugitive'             "Git wrapper
Plug 'flazz/vim-colorschemes'         "Plentiful colorschemes for vim
Plug 'morhetz/gruvbox'                "Gruvbox theme
Plug 'mileszs/ack.vim'                "Use ack-grep in vim
Plug 'christoomey/vim-tmux-navigator' "Seamless move between
Plug 'vim-python/python-syntax'       "Better python syntax highlighting

call plug#end()

syntax on
filetype plugin indent on

set nu
set cmdheight=1
set wildmenu
set wildmode=full
" tabs
set tabstop=4
set shiftwidth=4
set expandtab
set smarttab

set foldenable
set foldlevelstart=20
set foldmethod=indent
nnoremap , za

set autoindent
set smartindent
set cindent
" align function arguments in multiple lines
set cinoptions=(0,u0,U0
" change <leader> to space
let mapleader=" "

" save and restore session
nnoremap <leader>s :mksession! .session.vim <cr>
nnoremap <leader>r :so .session.vim <cr>

set hlsearch
nnoremap <leader>h :nohl<CR>
" when search the current word don't jump to next match
nnoremap <silent> * :let @/= '\<' . expand('<cword>') . '\>' <bar> set hls <cr>

" open tag in a new window
nnoremap <leader>] <C-w><C-]><C-w>T
" close tag window and jump back
nnoremap <leader>[ <C-w>c

hi Normal ctermbg=none
hi Visual term=reverse cterm=reverse
hi Search cterm=bold gui=bold ctermbg=LightRed ctermfg=Black guibg=LightRed guifg=Black

" colors for vimdiff
" green for addition
highlight DiffAdd    cterm=bold ctermfg=7 ctermbg=34 gui=none guifg=bg guibg=Red
" light pink for deletion
highlight DiffDelete cterm=bold ctermfg=7 ctermbg=8 gui=none guifg=bg guibg=Red
" blue for changes
highlight DiffChange cterm=bold ctermfg=7 ctermbg=27 gui=none guifg=bg guibg=Red
" red for different texts
highlight DiffText   cterm=bold ctermfg=7 ctermbg=9 gui=none guifg=bg guibg=Red

" Switch between split area
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-H> <C-W><C-H>
nnoremap <C-L> <C-W><C-L>
" some terminals recognize <C-H> as <BS>,
" vim won't receive <C-W><C-H> unless <BS> remapped
nnoremap <BS>  <C-W><C-H>

" Resize the current split area
nnoremap <TAB> :vertical resize +5<CR>
nnoremap <S-TAB> :vertical resize -5<CR>
" Browsing between vim tabs
nnoremap <C-P> :tabp<CR>
nnoremap <C-N> :tabn<CR>

" ------------- theme ---------------
set background=dark
autocmd vimenter * nested colorscheme gruvbox
let g:gruvbox_contrast_dark = 'soft'

" ------------ tagbar ------------
nnoremap <leader>t :TagbarToggle<CR>
let g:tagbar_width = 30
let g:tagbar_foldlevel = 2

" ------------ coc.nvim --------------
let g:coc_disable_startup_warning = 1
source $HOME/.vim/coc-settings.vim

" ------------ airline ------------
let g:airline#extensions#whitespace#enabled = 0

" gutentags conf
set statusline+=%{gutentags#statusline()}
let g:gutentags_project_root = ['.git', 'Makefile', 'CMakeLists.txt', 'package.json']

nnoremap <leader>e :NERDTreeToggle<CR>

" NerdCommenter conf
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
" Use compact syntax for prettified multi-line comments
" let g:NERDCompactSexyComs = 1
" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'
" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1
" Enable NERDCommenterToggle to check all selected lines is commented or not 
let g:NERDToggleCheckAllLines = 1
" comment delimiters for languages not defined in NERDCommenter
let g:NERDCustomDelimiters = {
    \ 'c': {'left': '//', 'leftAlt': '/*', 'rightAlt': '*/' },
    \ 'asm': {'left': '//', 'leftAlt': '/*', 'rightAlt': '*/' },
    \ 'bsv': {'left': '//', 'leftAlt': '/*', 'rightAlt': '*/' }
    \}

" Vim-tmux-navigator
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <C-H> :TmuxNavigateLeft<cr>
nnoremap <silent> <C-J> :TmuxNavigateDown<cr>
nnoremap <silent> <C-K> :TmuxNavigateUp<cr>
nnoremap <silent> <C-L> :TmuxNavigateRight<cr>
nnoremap <silent> <C-\> :TmuxNavigatePrevious<cr>

" special indent rules for bsv
autocmd FileType bsv set expandtab smarttab nocindent cinoptions=
autocmd BufNewFile,BufRead *.ms set ft=bsv
" bluespec indent
let b:verilog_indent_modules = 1
let b:verilog_indent_width = 4

" asm
autocmd FileType asm set tabstop=2 shiftwidth=2

let g:python_highlight_all = 1

