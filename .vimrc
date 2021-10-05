set nocompatible
set encoding=utf-8
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

Plugin 'Valloric/YouCompleteMe'         "Advanced autocomplete
Plugin 'majutsushi/tagbar'              "In-file navigation
Plugin 'ludovicchabant/vim-gutentags'   "Better ctags manager
Plugin 'preservim/nerdcommenter'        "Commenter
Plugin 'preservim/nerdtree'             "File navigator
Plugin 'bling/vim-airline'              "Fancy bottom bar
Plugin 'tpope/vim-fugitive'             "Git wrapper
Plugin 'flazz/vim-colorschemes'         "Plentiful colorschemes for vim
Plugin 'mileszs/ack.vim'                "Use ack-grep in vim
Plugin 'christoomey/vim-tmux-navigator' "Seamless move between
Plugin 'fatih/vim-go'                   " golang plugin

call vundle#end()

syntax on
filetype plugin indent on

" reload this vimrc
nnoremap <leader>r :source $MYVIMRC<CR>

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
" autocomplete in vim-go
" inoremap <C-c> <C-x><C-o>

" Tagbar plugin conf
nnoremap <leader>t :TagbarToggle<CR>
let g:tagbar_width = 30
let g:tagbar_foldlevel = 2
let updatetime=500

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
    \ 'bsv': {'left': '//', 'leftAlt': '/*', 'rightAlt': '*/' }
    \}

" airline conf
let g:airline_symbols_ascii = 1
let g:airline#extensions#tagbar#flags='s'

" ycm conf
" let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
" let g:ycm_confirm_extra_conf = 1
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_show_diagnostics_ui = 0
" " ycm debug
" let g:ycm_keep_logfiles = 1
" let g:ycm_log_level = 'debug'

" Vim-tmux-navigator
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <C-H> :TmuxNavigateLeft<cr>
nnoremap <silent> <C-J> :TmuxNavigateDown<cr>
nnoremap <silent> <C-K> :TmuxNavigateUp<cr>
nnoremap <silent> <C-L> :TmuxNavigateRight<cr>
nnoremap <silent> <C-\> :TmuxNavigatePrevious<cr>

" bluespec indent
let b:verilog_indent_modules = 1
let b:verilog_indent_width = 4
" special indent rules for bsv
autocmd FileType bsv set expandtab smarttab nocindent cinoptions=
autocmd BufRead,BufNew ms set ft=bsv

