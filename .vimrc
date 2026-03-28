" How to setup vim
"
set nocompatible                " choose no compatibility with legacy vi
syntax enable
set encoding=utf-8
set autoindent
set showcmd                     " display incomplete commands
filetype plugin indent on       " load file type plugins + indentation

"" Whitespace
set nowrap                      " don't wrap lines
set tabstop=2 shiftwidth=2      " a tab is two spaces (or set this to 4)
set expandtab                   " use spaces, not tabs (optional)
set backspace=indent,eol,start  " backspace through everything in insert mode

"" Searching
set hlsearch                    " highlight matches
set incsearch                   " incremental searching
set ignorecase                  " searches are case insensitive...
set smartcase                   " ... unless they contain at least one capital letter

" vim-plug: Vim plugin manager
"    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
"      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
" https://gist.github.com/benawad/b768f5a5bbd92c8baabd363b7e79786f
" :PlugInstall
" :PlugUpdate
" 
call plug#begin('~/.vim/plugged')
Plug 'junegunn/vim-easy-align'
Plug 'christoomey/vim-tmux-navigator'
Plug 'tpope/vim-commentary'
Plug 'williamboman/mason.nvim'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sensible'
Plug 'airblade/vim-gitgutter'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'https://github.com/nanotech/jellybeans.vim'
Plug 'jayli/vim-easycomplete'
" Plug 'SirVer/ultisnips'
Plug 'williamboman/nvim-lsp-installer'
call plug#end()

set background=dark
colorscheme jellybeans
" set rtp+=/opt/homebrew/opt/fzf

let g:copilot_enabled = v:true

" vim.g.easycomplete_enable_snippets = 1
" vim.g.easycomplete_enable = 1
" vim.g.easycomplete_cursor_word_hl = 1
" vim.g.easycomplete_nerd_font = 1

" NERDTree
map <C-n> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1

" FZF
map <C-p> :Files<CR>
map <C-b> :Buffers<CR>

