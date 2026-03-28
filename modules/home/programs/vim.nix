{ pkgs, ... }:
{
  programs.vim = {
    enable = true;
    extraConfig =
      builtins.readFile ../vimrc
      + "\n"
      + ''
        call plug#begin('~/.vim/plugged')
        Plug 'junegunn/vim-easy-align'
        Plug 'christoomey/vim-tmux-navigator'
        Plug 'tpope/vim-commentary'
        Plug 'williamboman/mason.nvim'
        Plug 'preservim/nerdtree'
        Plug 'Xuyuanp/nerdtree-git-plugin'
        Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
        Plug 'tpope/vim-fugitive'
        Plug 'tpope/vim-sensible'
        Plug 'airblade/vim-gitgutter'
        Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
        Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
        Plug 'nanotech/jellybeans.vim'
        Plug 'jayli/vim-easycomplete'
        Plug 'williamboman/nvim-lsp-installer'
        call plug#end()
      '';
  };
}
