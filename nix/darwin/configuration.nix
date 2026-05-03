{ pkgs, ... }:

let
  username = "takyshu98";
  homeDir = "/Users/${username}";
in
{
  system.defaults = {
    NSGlobalDomain = {
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
    };

    CustomUserPreferences = {
      NSGlobalDomain = {
        "com.apple.trackpad.scaling" = 3;
        "com.apple.mouse.scaling" = 3;
        "com.apple.scrollwheel.scaling" = 1;
      };
    };

    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };

    dock = {
      orientation = "left";
      autohide = true;
      showMissionControlGestureEnabled = true;
      showAppExposeGestureEnabled = true;
    };

    screencapture.location = "${homeDir}/var/screenshot";

    spaces.spans-displays = true;
  };

  # Run tap-to-click settings as the user since defaults write is user-specific
  system.activationScripts.postActivation.text = ''
    /usr/bin/su -l ${username} -c '
      defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
      defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
      defaults -currentHost write -g com.apple.mouse.tapBehavior -bool true
    '
  '';

  system.primaryUser = username;
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
