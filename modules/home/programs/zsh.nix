{ pkgs, ... }:
{
  # Note: all programs.* merged under one programs block to satisfy statix W20
  programs = {
    zsh = {
      enable = true;
      autocd = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      history = {
        size = 100000;
        save = 100000;
        share = true;
        ignoreDups = true;
        ignoreSpace = true;
        extended = true;
      };

      shellAliases = {
        # Navigation
        ".." = "cd ..";
        "..." = "cd ../..";
        "~" = "cd $HOME";

        # Better defaults
        #ls = "eza --icons";
        #ll = "eza -la --icons --git";
        #lt = "eza --tree --icons -L 2";
        cat = "bat --paging=never";
        grep = "rg";
        find = "fd";
        htop = "btop";
        top = "btop";

        # Git
        g = "git";
        ga = "git add";
        gc = "git commit";
        gp = "git push";
        gl = "git lg";
        gst = "git st";

        # Nix / home
        nix-rebuild = "darwin-rebuild switch --flake ~/.config/nix-home";
        nix-update = "nix flake update ~/.config/nix-home && nix-rebuild";
        nix-gc = "nix-collect-garbage -d";
        hm = "home-manager";

        # k8s
        k = "kubectl";
        kga = "kubectl get all";
        kns = "kubens";
        kctx = "kubectx";

        # Python
        py = "python3";
        pip = "uv pip";
      };

      oh-my-zsh = {
        enable = true;
        # No theme — starship handles the prompt
        plugins = [
          "git"
          "fzf"
          "direnv"
          "macos"
          "colored-man-pages"
          "command-not-found"
        ];
      };

      initContent = ''
        # ── fzf key bindings ──────────────────────────────────────────
        source ${pkgs.fzf}/share/fzf/key-bindings.zsh 2>/dev/null || true
        source ${pkgs.fzf}/share/fzf/completion.zsh   2>/dev/null || true

        # ── direnv ─────────────────────────────────────────────────────
        eval "$(direnv hook zsh)"

        # ── .NET ───────────────────────────────────────────────────────
        export DOTNET_ROOT="$(dirname $(which dotnet))"
        export DOTNET_CLI_TELEMETRY_OPTOUT=1

        # ── Local overrides ────────────────────────────────────────────
        [[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

        # ── Path additions ─────────────────────────────────────────────
        path=(
          "$HOME/bin"
          "$HOME/.local/bin"
          "$HOME/go/bin"
          "/opt/homebrew/bin"
          $path
        )
        export PATH
      '';
    };

    starship = {
      enable = true;
      settings = {
        format = "$all$character";
        add_newline = true;

        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
        };

        directory = {
          truncation_length = 4;
          truncate_to_repo = false;
        };

        git_branch.symbol = " ";
        python.symbol = " ";
        nodejs.symbol = " ";
        golang.symbol = " ";
        rust.symbol = " ";
        docker_context.symbol = " ";
        terraform.symbol = "󱁢 ";
        kubernetes = {
          disabled = false;
          symbol = "☸ ";
        };
      };
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    btop = {
      enable = true;
      settings = {
        color_theme = "gruvbox_dark";
        theme_background = false;
      };
    };
  };
}
