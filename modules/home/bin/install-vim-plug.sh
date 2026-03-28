#!/usr/bin/env bash
# Installs vim-plug for Vim if not already present
set -euo pipefail
PLUG_VIM="$HOME/.vim/autoload/plug.vim"
if [ ! -f "$PLUG_VIM" ]; then
  echo "Installing vim-plug to $PLUG_VIM ..."
  curl -fLo "$PLUG_VIM" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
  echo "vim-plug already installed at $PLUG_VIM"
fi
