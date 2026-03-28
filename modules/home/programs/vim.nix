{ pkgs, ... }:
{
  programs.vim = {
    enable = true;
    extraConfig = ''
      set nocompatible
      syntax enable
      set encoding=utf-8
      set autoindent
      set showcmd
      filetype plugin indent on
      set nowrap
      set tabstop=2 shiftwidth=2
      set expandtab
      set backspace=indent,eol,start
      set hlsearch
      set incsearch
      set ignorecase
      set smartcase
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
      Plug 'williamboman/nvim-lsp-installer'
      call plug#end()
      set background=dark
      colorscheme jellybeans
      let g:copilot_enabled = v:true
      map <C-n> :NERDTreeToggle<CR>
      let NERDTreeShowHidden=1
      map <C-p> :Files<CR>
      map <C-b> :Buffers<CR>
    '';
  };
}
