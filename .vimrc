set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

Plugin 'Valloric/YouCompleteMe'
Plugin 'majutsushi/tagbar'
Plugin 'bling/vim-airline'
Plugin 'scrooloose/nerdtree'

call vundle#end()

colorscheme molokai
syntax on
filetype plugin indent on
set nu
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4

set foldenable
set foldlevelstart=10
set foldmethod=indent
nnoremap <space> za

set autoindent
set smartindent
set cindent
set cinoptions=(0,u0,U0     " Align different lines of arguments

hi Normal ctermbg=none
let mapleader = ","         " Change <leader> to comma
                            " Switch between split area
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-H> <C-W><C-H>
nnoremap <C-L> <C-W><C-L>
                            " Tagbar plugin conf
nnoremap <leader>t :TagbarToggle<ENTER>
let g:tagbar_width = 35
" Browsing between vim tabs
nnoremap <leader>p :tabp<ENTER>
nnoremap <leader>n :tabn<ENTER>

let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'
let g:ycm_server_python_interpreter = '/usr/bin/python2'
let g:ycm_show_diagnostics_ui = 0
