{
  lib,
  pkgs,
  user,
  ...
}:
{
  imports = [
    ./packages.nix
    ./local-tools.nix
    ./programs/git.nix
    ./programs/zsh.nix
    ./programs/tmux.nix
    ./programs/neovim.nix
    ./programs/vscode.nix
    ./programs/vim.nix
    ./programs/podman.nix
    ./vim-plug.nix
  ];

  home = {
    username = user;
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${user}" else "/home/${user}";
    stateVersion = "24.05";

    # -- Session variables available in all shells --------------------
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less -R";
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    };
  };

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # Make iTerm2 open with a dark theme by default.
  home.activation.iterm2DarkTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    plist="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
    if command -v python3 >/dev/null 2>&1 && [ -f "$plist" ]; then
      python3 - "$plist" <<'PY'
import pathlib
import plistlib
import sys

path = pathlib.Path(sys.argv[1])
with path.open('rb') as f:
    data = plistlib.load(f)

data['TabStyleWithAutomaticOption'] = 1

with path.open('wb') as f:
    plistlib.dump(data, f)
PY
    fi
  '';

  # XDG base dirs
  xdg.enable = true;
}
