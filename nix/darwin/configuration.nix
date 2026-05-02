{ pkgs, ... }:

let
  username = "takyshu98";
  homeDir = "/Users/${username}";
in
{
  system.defaults = {
    NSGlobalDomain = {
      "com.apple.trackpad.scaling" = 3;
      "com.apple.mouse.scaling" = 3;
      "com.apple.scrollwheel.scaling" = 1;
      "com.apple.mouse.tapBehavior" = 1;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
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

  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
