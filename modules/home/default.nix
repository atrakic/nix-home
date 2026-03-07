{ user, ... }: {
  imports = [
    ./packages.nix
    ./local-tools.nix
    ./programs/git.nix
    ./programs/zsh.nix
    ./programs/tmux.nix
    ./programs/neovim.nix
    ./programs/vscode.nix
  ];

  home = {
    username      = user;
    homeDirectory = "/Users/${user}";
    stateVersion  = "24.05";

    # ── Session variables available in all shells ────────────────────
    sessionVariables = {
      EDITOR  = "nvim";
      VISUAL  = "nvim";
      PAGER   = "less -R";
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    };
  };

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # XDG base dirs
  xdg.enable = true;
}
