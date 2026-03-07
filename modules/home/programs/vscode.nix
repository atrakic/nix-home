{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode; # switch to pkgs.vscodium for open-source build

    # ── Extensions ────────────────────────────────────────────────────
    extensions = with pkgs.vscode-extensions; [
      # ── AI ───────────────────────────────────────────────────────────
      github.copilot
      github.copilot-chat

      # ── Python ───────────────────────────────────────────────────────
      ms-python.python
      ms-python.pylance
      ms-python.debugpy
      charliermarsh.ruff

      # ── TypeScript / JavaScript ───────────────────────────────────────
      dbaeumer.vscode-eslint
      esbenp.prettier-vscode

      # ── Go ────────────────────────────────────────────────────────────
      golang.go

      # ── Rust ─────────────────────────────────────────────────────────
      rust-lang.rust-analyzer

      # ── Nix ──────────────────────────────────────────────────────────
      jnoortheen.nix-ide

      # ── Infrastructure / Cloud ────────────────────────────────────────
      hashicorp.terraform
      redhat.vscode-yaml
      tamasfe.even-better-toml

      # ── Notebooks / Data ──────────────────────────────────────────────
      ms-toolsai.jupyter

      # ── Git ──────────────────────────────────────────────────────────
      eamodio.gitlens

      # ── Remote / Containers ───────────────────────────────────────────
      ms-vscode-remote.remote-containers

      # ── Editors / UX ──────────────────────────────────────────────────
      vscodevim.vim
      catppuccin.catppuccin-vsc
      catppuccin.catppuccin-vsc-icons
      editorconfig.editorconfig
      gruntfuggly.todo-tree
      streetsidesoftware.code-spell-checker
      usernamehw.errorlens
      timonwong.shellcheck
    ];
    # ── Marketplace extensions (requires sha256 hash) ─────────────────
    # Uncomment and add the correct sha256 (run `nix-prefetch-url <vsix-url>`):
    #
    # ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    #   {
    #     name      = "vscode-database-client2";
    #     publisher = "cweijan";
    #     version   = "8.7.0";
    #     sha256    = "sha256-REPLACE_ME";
    #   }
    #   {
    #     name      = "remote-ssh";
    #     publisher = "ms-vscode-remote";
    #     version   = "0.116.2024";
    #     sha256    = "sha256-REPLACE_ME";
    #   }
    # ];

    # ── User settings ─────────────────────────────────────────────────
    userSettings = {
      # Appearance
      "workbench.colorTheme" = "Catppuccin Mocha";
      "workbench.iconTheme" = "catppuccin-mocha";
      "editor.fontFamily" = "'JetBrains Mono', 'Fira Code', monospace";
      "editor.fontSize" = 13;
      "editor.lineHeight" = 1.6;
      "editor.fontLigatures" = true;
      "editor.renderWhitespace" = "boundary";
      "editor.cursorBlinking" = "smooth";
      "editor.smoothScrolling" = true;
      "terminal.integrated.fontSize" = 12;
      "workbench.startupEditor" = "none";

      # Editor behaviour
      "editor.tabSize" = 2;
      "editor.insertSpaces" = true;
      "editor.formatOnSave" = true;
      "editor.codeActionsOnSave" = {
        "source.fixAll.eslint" = "explicit";
        "source.organizeImports" = "explicit";
      };
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
      "editor.minimap.enabled" = false;
      "editor.rulers" = [
        88
        120
      ];
      "editor.bracketPairColorization.enabled" = true;
      "editor.guides.bracketPairs" = true;

      # Files
      "files.trimTrailingWhitespace" = true;
      "files.insertFinalNewline" = true;
      "files.autoSave" = "onFocusChange";
      "files.exclude" = {
        "**/__pycache__" = true;
        "**/.pytest_cache" = true;
        "**/node_modules" = true;
        "**/.direnv" = true;
      };

      # Git
      "git.confirmSync" = false;
      "git.autofetch" = true;
      "gitlens.codeLens.enabled" = false; # reduces noise

      # Python
      "python.defaultInterpreterPath" = "python3";
      "[python]"."editor.defaultFormatter" = "charliermarsh.ruff";
      "ruff.organizeImports" = true;

      # Nix
      "[nix]"."editor.defaultFormatter" = "jnoortheen.nix-ide";
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nil";

      # Vim (vscodevim)
      "vim.leader" = "<space>";
      "vim.useSystemClipboard" = true;
      "vim.hlsearch" = true;
      "vim.normalModeKeyBindingsNonRecursive" = [
        {
          "before" = [
            "<leader>"
            "w"
          ];
          "commands" = [ "workbench.action.files.save" ];
        }
        {
          "before" = [
            "<leader>"
            "e"
          ];
          "commands" = [ "workbench.view.explorer" ];
        }
        {
          "before" = [
            "<leader>"
            "f"
            "f"
          ];
          "commands" = [ "workbench.action.quickOpen" ];
        }
        {
          "before" = [
            "<leader>"
            "f"
            "g"
          ];
          "commands" = [ "workbench.view.search" ];
        }
      ];

      # Terminal
      "terminal.integrated.shell.osx" = "/bin/zsh";
      "terminal.integrated.defaultProfile.osx" = "zsh";
      "terminal.integrated.scrollback" = 10000;

      # Copilot
      "github.copilot.enable" = {
        "*" = true;
      };

      # Explorer
      "explorer.confirmDelete" = false;
      "explorer.confirmDragAndDrop" = false;

      # Telemetry
      "telemetry.telemetryLevel" = "off";
      "redhat.telemetry.enabled" = false;
    };

    # ── Keyboard shortcuts ────────────────────────────────────────────
    keybindings = [
      {
        key = "ctrl+shift+`";
        command = "workbench.action.terminal.new";
      }
      {
        key = "cmd+j";
        command = "workbench.action.togglePanel";
      }
      {
        key = "cmd+b";
        command = "workbench.action.toggleSidebarVisibility";
      }
      {
        key = "cmd+shift+e";
        command = "workbench.view.explorer";
      }
    ];
  };
}
