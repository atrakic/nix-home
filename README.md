# nix-home

> Developer environment — **one command to rule them all**.

A **modular, flake-based** nix-darwin + home-manager configuration for a data / full-stack workflow.

---

## Quick start

### Fresh machine (first run)

```bash
# Option A — pipe installer directly
curl -fsSL https://raw.githubusercontent.com/atrakic/nix-home/main/install.sh | bash

# Option B — clone first, then run
git clone https://github.com/atrakic/nix-home ~/.config/nix-home
cd ~/.config/nix-home && bash install.sh
```

### Already have Nix?

```bash
git clone https://github.com/atrakic/nix-home ~/.config/nix-home
cd ~/.config/nix-home
# 1. Add your machine to darwinHosts / linuxHosts in flake.nix (key = hostname -s)
# 2. Bootstrap & apply:
make bootstrap   # first time — installs nix-darwin (requires sudo)
make             # apply config
```

---

## Day-to-day commands

| Command          | Description                                   |
| ---------------- | --------------------------------------------- |
| `make`           | ★ Apply all config changes                    |
| `make bootstrap` | First-time nix-darwin install (requires sudo) |
| `make update`    | Update all flake inputs, then apply           |
| `make check`     | Evaluate flake without building (fast lint)   |
| `make fmt`       | Format all `.nix` files                       |
| `make gc`        | Garbage-collect old Nix store generations     |
| `make diff`      | Preview what would change (dry-run)           |
| `make help`      | List all targets                              |

The Makefile auto-detects your hostname (`hostname -s`) and selects the
matching `darwinConfigurations` / `nixosConfigurations` entry from the flake.

---

## Repo layout

```
nix-home/
├── flake.nix                  ← entry point; machine registry + config builders
├── Makefile                   ← make = apply full config (auto-detects hostname)
├── install.sh                 ← one-shot bootstrap for a new machine
└── modules/
    ├── darwin/
    │   ├── default.nix        ← macOS system settings, nix-daemon
    │   └── homebrew.nix       ← GUI apps via Homebrew Cask
    └── home/
        ├── default.nix        ← home-manager root
        ├── packages.nix       ← CLI tools, languages, infra
        └── programs/
            ├── git.nix        ← git + delta
            ├── zsh.nix        ← zsh + starship + zoxide + btop
            ├── tmux.nix       ← tmux + vim-keys + catppuccin
            ├── neovim.nix     ← neovim with LSP, completion, formatting
            └── vscode.nix     ← VSCode extensions + settings
```

---

## Customisation

### Add a new machine

Add an entry to `darwinHosts` (macOS) or `linuxHosts` (NixOS) in [`flake.nix`](flake.nix).
The key **must** match `hostname -s` on that machine:

```nix
darwinHosts = {
  "Admirs-MacBook-Pro-M1" = { system = "aarch64-darwin"; user = "adtr"; };
  "My-New-Mac"            = { system = "aarch64-darwin"; user = "me";   };
};
```

Then on the new machine: `make bootstrap && make`.

### Add a new CLI tool

Add a package to [`modules/home/packages.nix`](modules/home/packages.nix) and run `make`.

### Add a macOS GUI app (Homebrew Cask)

Add a cask name to [`modules/darwin/homebrew.nix`](modules/darwin/homebrew.nix) and run `make`.

### Add a new program module

1. Create `modules/home/programs/mytool.nix`
2. Import it in `modules/home/default.nix`

---

## What's included

### Shell & terminal
- **zsh** — autosuggestions, syntax highlighting, 100k history
- **Starship** — async prompt with git/k8s/language context
- **zoxide** — smarter `cd`
- **fzf / ripgrep / fd / bat / eza / delta** — modern Unix replacements
- **tmux** — prefix `C-a`, vim keys, catppuccin theme, auto-save/restore

### Neovim
- **lazy.nvim** (nix-managed) — fast plugin loading
- **LSPs**: nil (Nix), pyright, ts_ls, gopls, rust-analyzer, terraformls, yamlls, bashls
- **Treesitter** — syntax for all major languages
- **Telescope** — fuzzy find files/grep/buffers
- **conform.nvim** — auto-format on save
- **nvim-cmp** — completion + snippets
- Catppuccin theme → Tokyo Night night

### VSCode extensions
| Category      | Extensions                                            |
| ------------- | ----------------------------------------------------- |
| AI            | GitHub Copilot, Copilot Chat                          |
| Python        | Python, Pylance, Debugpy, Ruff                        |
| TypeScript/JS | ESLint, Prettier, Tailwind CSS                        |
| Go            | Official Go extension                                 |
| Rust          | rust-analyzer                                         |
| Nix           | nix-ide                                               |
| Infra         | Terraform, YAML, TOML                                 |
| Data          | Jupyter, Database Client                              |
| Git           | GitLens, Git Graph                                    |
| Remote        | Remote SSH, Dev Containers                            |
| UX            | Vim, Catppuccin, Error Lens, Todo Tree, Spell Checker |

### Languages & runtimes
`python3`, `uv`, `nodejs 22`, `go`, `rustup`

### Data tools
`postgresql` (psql client), `redis-cli`, `duckdb`, `jq`, `yq`

### Cloud / Infra
`kubectl`, `kubectx`, `helm`, `k9s`

### macOS apps (Homebrew Cask)
Podman Desktop, TablePlus, Insomnia, iTerm2, Rectangle, Tailscale, VLC

---

## Prerequisites

| Requirement        | Notes                                           |
| ------------------ | ----------------------------------------------- |
| macOS 14+ (Sonoma) | arm64 or x86_64                                 |
| Xcode CLT          | `xcode-select --install`                        |
| Nix                | Installed by `install.sh` (Determinate Systems) |

---

## Troubleshooting

**`/etc/zshrc` conflict on first run**

```bash
sudo mv /etc/zshrc /etc/zshrc.backup
```

**Extension hash mismatch (marketplace extensions)**

Update the `sha256` in `vscode.nix` using:

```bash
nix-prefetch-url "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/PUBLISHER/vsextensions/NAME/VERSION/vspackage"
```

**Nix store corrupted**

```bash
sudo nix-store --verify --repair
```
