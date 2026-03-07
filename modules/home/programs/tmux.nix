{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "screen-256color";
    historyLimit = 50000;
    prefix = "C-a";
    escapeTime = 0;
    baseIndex = 1;
    mouse = true;
    keyMode = "vi";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank # system clipboard
      {
        plugin = resurrect;
        extraConfig = "set -g @resurrect-capture-pane-contents 'on'";
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '10'
        '';
      }
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'mocha'
          set -g @catppuccin_window_tabs_enabled 'on'
        '';
      }
    ];

    extraConfig = ''
      # ── Pane splitting ───────────────────────────────────────────────
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # ── Pane navigation (vim-style) ──────────────────────────────────
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # ── Window navigation ────────────────────────────────────────────
      bind -n M-H previous-window
      bind -n M-L next-window

      # ── Reload config ─────────────────────────────────────────────────
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

      # ── Copy mode ────────────────────────────────────────────────────
      bind -T copy-mode-vi v   send-keys -X begin-selection
      bind -T copy-mode-vi y   send-keys -X copy-selection-and-cancel

      # ── True colour support ──────────────────────────────────────────
      set -as terminal-features ",xterm-256color:RGB"
      set -ga terminal-overrides "*:Tc"
    '';
  };
}
