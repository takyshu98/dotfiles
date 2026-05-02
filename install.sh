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

# Install Nix
if ! command -v nix >/dev/null 2>&1; then
  curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install --no-modify-profile --no-confirm
  echo
fi

# Source Nix for the current session
# shellcheck disable=SC1091
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

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

# Apply nix-darwin configuration (replaces scripts/defaults.sh)
if command -v darwin-rebuild >/dev/null 2>&1; then
  sudo darwin-rebuild switch --flake "${DOTPATH}/nix#default"
else
  sudo nix run nix-darwin -- switch --flake "${DOTPATH}/nix#default"
fi
echo

# Restore application settings
# mackup -v restore
# echo

echo "Installation completed!"