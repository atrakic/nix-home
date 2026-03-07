{ ... }:
{
  # ── Homebrew ─────────────────────────────────────────────────────────
  # GUI apps and things not in nixpkgs. Nix manages the brew binary itself.
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap"; # remove unlisted formulae/casks
    };

    taps = [
      "homebrew/bundle"
    ];

    brews = [
      "mas" # Mac App Store CLI
    ];

    casks = [
      # ── Browsers ────────────────────────────────────────────────────
      "google-chrome"

      # ── Dev tools ───────────────────────────────────────────────────
      "podman-desktop" # OCI container GUI (Docker alternative)
      "tableplus" # DB GUI (Postgres, MySQL, Redis, …)
      "insomnia" # REST / GraphQL client
      "iterm2"

      # ── Productivity ─────────────────────────────────────────────────
      "rectangle" # Window manager
      "displaylink" # DisplayLink Manager (external displays)

      # ── Network ──────────────────────────────────────────────────────
      "tailscale" # VPN mesh network

      # ── Media ────────────────────────────────────────────────────────
      "vlc" # Media player

      # ── Communication ────────────────────────────────────────────────
      "slack"
    ];

    masApps = {
      # "Xcode" = 497799835;   # uncomment if you need Xcode
    };
  };
}
