#!/bin/bash

set -e

echo "==> Configuring Trackpad options..."

# Change cursor speed faster
defaults write -g com.apple.trackpad.scaling -int 3

# Activate tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write -g com.apple.mouse.tapBehavior -bool true

# Activate three finger drag
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

# Activate four finger app expose
defaults write com.apple.dock showMissionControlGestureEnabled -bool true
defaults write com.apple.dock showAppExposeGestureEnabled -bool true

echo "==> Configuring Mouse options..."

# Change cursor speed faster
defaults write -g com.apple.mouse.scaling 3

# Change scroll speed faster
defaults write -g com.apple.scrollwheel.scaling 1

echo "==> Configuring Other options..."

# Deactivate auto capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool "false"

# Deactivate auto spell correction
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool "false"