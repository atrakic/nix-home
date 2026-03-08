{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode; # switch to pkgs.vscodium for open-source build

    profiles.default = {
      # ── Extensions ──────────────────────────────────────────────────
      extensions = with pkgs.vscode-extensions; [
        # ── AI ─────────────────────────────────────────────────────────
        github.copilot
        github.copilot-chat

        # ── Python ─────────────────────────────────────────────────────
        ms-python.python
        ms-python.debugpy
        charliermarsh.ruff

        # ── TypeScript / JavaScript ─────────────────────────────────────
        dbaeumer.vscode-eslint
        esbenp.prettier-vscode

        # ── Go ──────────────────────────────────────────────────────────
        golang.go

        # ── Nix ─────────────────────────────────────────────────────────
        jnoortheen.nix-ide

        # ── Infrastructure / Cloud ──────────────────────────────────────
        redhat.vscode-yaml

        # ── Notebooks / Data ────────────────────────────────────────────
        ms-toolsai.jupyter

        # ── Git ─────────────────────────────────────────────────────────
        eamodio.gitlens

        # ── Remote / Containers ─────────────────────────────────────────
        ms-vscode-remote.remote-containers

        # ── Editors / UX ────────────────────────────────────────────────
        vscodevim.vim
        editorconfig.editorconfig
        # ── Marketplace extensions (add sha256 and uncomment to enable) ──
        # Use: nix-prefetch-url <vsix-url>
        # ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [ { ... } ]
      ];

      # ── User settings ────────────────────────────────────────────────
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
        "gitlens.codeLens.enabled" = false;

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
        "terminal.integrated.scrollback" = 10000;

        # Copilot
        "github.copilot.enable"."*" = true;

        # Explorer
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;

        # Telemetry
        "telemetry.telemetryLevel" = "off";
        "redhat.telemetry.enabled" = false;
      };

      # ── Keyboard shortcuts ───────────────────────────────────────────
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
  };
}
