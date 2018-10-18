set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

Plugin 'Valloric/YouCompleteMe' "Advanced autocomplete
Plugin 'majutsushi/tagbar'      "In-file navigation
Plugin 'bling/vim-airline'      "Fancy bottom bar
Plugin 'scrooloose/nerdtree'    "File explorer
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
nnoremap <leader>fm  :set foldmethod=manual<ENTER>
nnoremap <leader>fi  :set foldmethod=indent<ENTER>
nnoremap <space> za

set autoindent
set smartindent
set cindent
set cinoptions=(0,u0,U0     " Align different lines of arguments

hi Normal ctermbg=none
hi Visual term=reverse cterm=reverse guibg=Grey
let mapleader = ","         " Change <leader> to comma
                            " Switch between split area
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-H> <C-W><C-H>
nnoremap <C-L> <C-W><C-L>
                            " Tagbar plugin conf
nnoremap <leader>t :TagbarToggle<ENTER>
let g:tagbar_width = 30
" Browsing between vim tabs
nnoremap <leader>p :tabp<ENTER>
nnoremap <leader>n :tabn<ENTER>

let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_show_diagnostics_ui = 0

"Configuration for vim-easytags
let g:easytags_file = '~/.vim/tags'
let g:easytags_by_filetype = '~/.vim/tags'
let g:easytags_events = ['BufWritePost']
let g:easytags_on_cursorhold = 0    " Don't update tags until there is a file write
let g:easytags_async = 1            " Enable async mode: won't block foreground

"Vim-tmux-navigator 
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> {Left-Mapping} :TmuxNavigateLeft<cr>
nnoremap <silent> {Down-Mapping} :TmuxNavigateDown<cr>
nnoremap <silent> {Up-Mapping} :TmuxNavigateUp<cr>
nnoremap <silent> {Right-Mapping} :TmuxNavigateRight<cr>
nnoremap <silent> {Previous-Mapping} :TmuxNavigatePrevious<cr>
