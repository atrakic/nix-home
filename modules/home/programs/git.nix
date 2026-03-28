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
      push = {
        default = "current";
        autoSetupRemote = true;
      };
      diff = {
        #external = "/usr/bin/vimdiff";
        renames = "copies";
        mnemonicprefix = true;
        submodule = "log";
      };
      branch = {
        autosetupmerge = true;
        autosetuprebase = "remote";
      };
      merge.stat = true;
      #merge.tool = "xxdiff";
      color.ui = "auto";
      rerere.enabled = true;
      advice = {
        statusHints = true;
        pushNonFastForward = false;
      };
      fetch.prune = true;
      help.autocorrect = 1;
      status.submoduleSummary = true;
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
