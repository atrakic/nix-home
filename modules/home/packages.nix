{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # -- Shell utilities ----------------------------------------------
    bat # better cat
    eza # better ls
    fd # better find
    fzf # fuzzy finder
    ripgrep # better grep
    delta # better git diff
    jq # JSON processor
    yq-go # YAML/TOML/XML processor
    gron # greppable JSON
    tldr # practical man pages
    tree
    watch
    hyperfine # benchmarking
    dust # better du
    duf # better df
    procs # better ps

    # -- Network ------------------------------------------------------
    curl
    wget
    httpie
    nmap
    mtr

    # -- Dev ----------------------------------------------------------
    git
    git-lfs
    tig
    gh # GitHub CLI
    pre-commit
    direnv
    just # command runner (justfile)
    gnupg
    age # modern encryption
    sops # secrets management

    # -- Languages & runtimes -----------------------------------------
    python313
    uv # fast Python package manager
    nodejs_22
    go
    rustup
    dotnet-sdk_10 # .NET 10 (latest)

    # -- Data ---------------------------------------------------------
    postgresql # psql client
    redis # redis-cli
    duckdb

    # -- Cloud / Infra -------------------------------------------------
    kubectl
    kubectx
    kubernetes-helm
    k9s # Kubernetes TUI

    # -- Misc ---------------------------------------------------------
    fastfetch # system info (neofetch replacement)
    yt-dlp # download YouTube / 1000+ sites
    nixfmt # nix formatter
    nil # nix LSP
  ];
}
