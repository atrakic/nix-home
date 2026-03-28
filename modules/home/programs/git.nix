{ pkgs, ... }:
{
  programs.git = {
    enable = true;

    settings = {
      user.name = "adtr";
      user.email = "adtr@users.noreply.github.com"; # change to your email

      alias = {
        lg = "log --oneline --graph --decorate --all";
        st = "status -sb";
        co = "checkout";
        br = "branch";
        oops = "commit --amend --no-edit";
        undo = "reset --soft HEAD~1";
        wip = "!git add -A && git commit -m 'wip'";
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      rebase.autoStash = true;
      merge.conflictstyle = "zdiff3";
      diff.algorithm = "histogram";
      core = {
        editor = "nvim";
        autocrlf = "input";
        whitespace = "trailing-space,space-before-tab";
      };
      # macOS keychain - ignored on Linux
      credential.helper = pkgs.lib.optionalString pkgs.stdenv.isDarwin "osxkeychain";
      url."git@github.com:".insteadOf = "https://github.com/";
    };

    ignores = [
      ".DS_Store"
      "*.swp"
      ".direnv/"
      ".env"
      ".env.local"
      "__pycache__/"
      "*.pyc"
      ".pytest_cache/"
      "node_modules/"
      ".vscode/settings.json"
    ];
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
      syntax-theme = "gruvbox-dark";
    };
  };
}
