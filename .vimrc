set nocompatible
set encoding=utf-8
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

Plugin 'Valloric/YouCompleteMe' "Advanced autocomplete
Plugin 'scrooloose/nerdtree'    "File explorer
Plugin 'majutsushi/tagbar'      "In-file navigation
Plugin 'bling/vim-airline'      "Fancy bottom bar
Plugin 'tpope/vim-fugitive'     "Git wrapper
Plugin 'xolox/vim-misc'         "Required by vim-easytags
Plugin 'xolox/vim-easytags'     "Auto update ctags file
Plugin 'flazz/vim-colorschemes' "Plentiful colorschemes for vim
Plugin 'mileszs/ack.vim'        "Use ack-grep in vim
Plugin 'christoomey/vim-tmux-navigator' "Seamless move between

call vundle#end()

colorscheme molokai
syntax on
filetype plugin indent on
set nu
set cmdheight=1
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4

set foldenable
set foldlevelstart=10
set foldmethod=indent
nnoremap , za

set autoindent
set smartindent
set cindent
set cinoptions=(0,u0,U0     " Align different lines of arguments
let mapleader=" "         " Change <leader> to space

hi Normal ctermbg=none
hi Visual term=reverse cterm=reverse guibg=Grey


" Switch between split area
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-H> <C-W><C-H>
nnoremap <C-L> <C-W><C-L>
nnoremap <leader>r <C-W>b
" Resize the current split area
nnoremap <TAB> :vertical resize +5<ENTER>
nnoremap <S-TAB> :vertical resize -5<ENTER>
" Browsing between vim tabs
nnoremap <C-P> :tabp<ENTER>
nnoremap <C-N> :tabn<ENTER>

vnoremap // y/<C-R>"<CR>
" indent for bsv files
let b:verilog_indent_modules = 1

" Tagbar plugin conf
nnoremap <leader>t :TagbarToggle<ENTER>
let g:tagbar_width = 30
let updatetime=500

" nerdtree conf
nnoremap <leader>N :NERDTreeToggle<ENTER>
let g:NERDTreeWinSize=25

" airline conf
let g:airline_symbols_ascii = 1
let g:airline#extensions#tagbar#flags='s'

" ycm conf
let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
let g:ycm_confirm_extra_conf = 0
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_show_diagnostics_ui = 1
" " ycm debug
" let g:ycm_keep_logfiles = 1
" let g:ycm_log_level = 'debug'

"Configuration for vim-easytags
let g:easytags_file = '~/.vim/tags'
let g:easytags_by_filetype = '~/.vim/tags'
let g:easytags_events = ['BufWritePost']
let g:easytags_on_cursorhold = 0    " Don't update tags until there is a file write
let g:easytags_async = 1            " Enable async mode: won't block foreground

"Vim-tmux-navigator
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <C-H> :TmuxNavigateLeft<cr>
nnoremap <silent> <C-J> :TmuxNavigateDown<cr>
nnoremap <silent> <C-K> :TmuxNavigateUp<cr>
nnoremap <silent> <C-L> :TmuxNavigateRight<cr>
nnoremap <silent> <C-\> :TmuxNavigatePrevious<cr>
