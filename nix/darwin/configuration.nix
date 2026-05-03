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

  # tapBehavior requires -currentHost write, not handled by CustomUserPreferences
  system.activationScripts.postActivation.text = ''
    defaults -currentHost write -g com.apple.mouse.tapBehavior -bool true
  '';

  system.primaryUser = username;
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
