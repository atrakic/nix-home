{ pkgs, ... }:
{
  imports = [ ./homebrew.nix ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      warn-dirty = false;
    };
    gc = {
      automatic = true;
      interval = {
        Hour = 3;
        Minute = 0;
      }; # weekly at 3am
      options = "--delete-older-than 14d";
    };
  };

  # -- Shell ------------------------------------------------------------
  programs.zsh.enable = true;

  environment.systemPackages = [ pkgs.vim ]; # bare minimum in PATH

  # -- macOS system defaults --------------------------------------------
  system.defaults = {
    dock = {
      autohide = true;
      show-recents = false;
      mru-spaces = false;
    };
    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "clmv"; # column view
      ShowPathbar = true;
      _FXShowPosixPathInTitle = true;
    };
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleKeyboardUIMode = 3;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
    };
    trackpad = {
      Clicking = true; # tap-to-click
      TrackpadThreeFingerDrag = true;
    };
    screensaver.askForPassword = true;
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.stateVersion = 5;
}
