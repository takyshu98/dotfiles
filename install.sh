#!//bin/bash

set -eu

readonly ARCH_TYPE="$(arch)"
readonly DOTPATH="${HOME}/share/dotfiles"

echo -e "\nInstallation has started...\n"
echo -e "My architecture: ${ARCH_TYPE}\n"

# Install Rosetta 2 for Apple silicon
if [ "${ARCH_TYPE}" = "arm64" ]; then
  softwareupdate --install-rosetta --agree-to-license
  echo
fi

# Install Homebrew
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo
fi

# Export brew path to Homebrew Bundle
if [ "${ARCH_TYPE}" = "i386" ]; then
  export PATH="/usr/local/bin:${PATH}"    # for Intel
elif [ "${ARCH_TYPE}" = "arm64" ]; then
  export PATH="/opt/homebrew/bin:${PATH}" # for Apple silicon
fi

# Clone repository
if [ ! -d "${DOTPATH}" ]; then
  git clone https://github.com/takyshu98/dotfiles.git "${DOTPATH}"
else
  echo "Already downloaded: ${DOTPATH}"
  echo "Stash local changes and updating..."
  git -C "${DOTPATH}" stash
  git -C "${DOTPATH}" switch master
  git -C "${DOTPATH}" pull origin master
  echo
fi

# Install command line tools and applications
brew bundle --file "${DOTPATH}/Brewfile"
echo

# Make symbolic links and directories
"${DOTPATH}/scripts/symlink.sh"
echo

# Restore macOS settings
"${DOTPATH}/scripts/defaults.sh"
echo

# Restore application settings
# mackup -v restore
# echo

echo "Installation completed!"