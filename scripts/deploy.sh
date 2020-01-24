#!/usr/bin/env bash

DOTPATH=$HOME/share/dotfiles

if [ ! -e "$DOTPATH" ]; then
  echo "Error: Directory $DOTPATH does not exist."
  exit 1
fi

cd "$DOTPATH" || exit 1

# make symbolic links from ~/.* to ~/share/dotfiles/.*
for file in .??*; do
  [[ "$file" == ".git" ]] && continue
  [[ "$file" == ".gitignore" ]] && continue
  [[ "$file" == ".DS_Store" ]] && continue
  [[ "$file" == ".travis.yml" ]] && continue
  ln -fvns "$DOTPATH/$file" "$HOME/$file"
done

# make symbolic links from ~/bin/.* to ~/share/dotfiles/bin/.*
if [ ! -d ~/bin ]; then
  echo "Error: Directory ~/bin does not exist."
  exit 1
else
  find "$DOTPATH/bin/" -type f -exec ln -fvns {} ~/bin/ \;
fi
