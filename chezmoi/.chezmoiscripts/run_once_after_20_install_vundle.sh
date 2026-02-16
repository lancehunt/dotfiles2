#!/bin/bash

VUNDLE_DIR="$HOME/.vim/bundle/Vundle.vim"

if [ ! -d "$VUNDLE_DIR" ]; then
  echo "Installing Vundle..."
  git clone https://github.com/VundleVim/Vundle.vim.git "$VUNDLE_DIR"
fi

echo "Installing Vim plugins..."
vim +PluginInstall +qall
