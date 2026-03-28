{ pkgs, ... }:
{
  programs.git = {
    enable = true;

    settings = {
      user.name = "adtr";
      user.email = "adtr@users.noreply.github.com"; # change to your email

      alias = {
        sha = "rev-parse HEAD";
        last = "log -1 HEAD";
        ci = "commit";
        br = "branch";
        co = "checkout";
        staged = "diff --cached";
        lg = "log --oneline --graph --decorate --all";
        up = "!git remote update -p; git merge --ff-only @{u}";
        logc = "log --color --graph --pretty=format:'%Cred%h%Creset-%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";
        st = "status -sb";
        amend = "commit -a --amend";
        save = "!git add -A && git commit -m 'SAVEPOINT'";
        tree = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
        oops = "commit --amend --no-edit";
        undo = "reset --soft HEAD~1";
        wip = "!git add -A && git commit -m 'wip'";
        merged = "!git branch -a --merged"; # list merged branches
        cherry-pick = "!f() { git rebase $1^ ; }; f"; # 1 - commitid
        # LeaderBoards:
        rank = "shortlog -sn --all --no-merges";
        stats = "!git shortlog -sn --since='10 weeks' --until='2 weeks'";
        everyone = "!git log --all --oneline --no-merges"; # see what everyones been getting up to
        overview = "!git log --all --since='2 weeks' --oneline --no-merges";
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
