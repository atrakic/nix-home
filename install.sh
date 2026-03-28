#!/usr/bin/env bash
# ── install.sh ───────────────────────────────────────────────────────────────
# Bootstrap a brand-new macOS machine with nix-darwin + home-manager.
# Run this ONCE on a fresh machine.
#
#   curl -fsSL https://raw.githubusercontent.com/atrakic/nix-home/main/install.sh | bash
#
# Or clone first:
#   git clone https://github.com/atrakic/nix-home ~/.config/nix-home
#   cd ~/.config/nix-home && bash install.sh
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

REPO_DIR="${REPO_DIR:-$HOME/.config/nix-home}"
NIX_CONF="/etc/nix/nix.conf"
TARGET_HOST="${TARGET_HOST:-$(hostname -s 2>/dev/null || echo "unknown")}"  # must match flake key

step() { echo -e "\033[1;34m==>\033[0m $*"; }
ok()   { echo -e "\033[1;32m ✓\033[0m  $*"; }
warn() { echo -e "\033[1;33m !\033[0m  $*"; }
die()  { echo -e "\033[1;31mERROR:\033[0m $*" >&2; exit 1; }

[[ "$(uname)" == "Darwin" ]] || die "macOS only"

# ── 1. Install Nix (official installer) ───────────────────────────────────────
if ! command -v nix &>/dev/null; then
  step "Installing Nix via official installer (nixos.org)…"
  curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --daemon --yes
  # shellcheck disable=SC1091
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  ok "Nix installed: $(nix --version)"
else
  ok "Nix already installed: $(nix --version)"
fi

# Make sure nix-darwin binaries are reachable in non-login shells.
export PATH="/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH"

# ── 2. Enable flakes (just in case the installer didn't) ─────────────────────
if [[ -f "$NIX_CONF" ]] && ! grep -q "experimental-features" "$NIX_CONF"; then
  step "Enabling flakes in $NIX_CONF…"
  echo "experimental-features = nix-command flakes" | sudo tee -a "$NIX_CONF"
fi

# ── 3. Clone repo if needed ───────────────────────────────────────────────────
if [[ ! -d "$REPO_DIR" ]]; then
  step "Cloning nix-home to $REPO_DIR…"
  git clone https://github.com/atrakic/nix-home "$REPO_DIR"
else
  ok "Repo already present at $REPO_DIR"
fi

cd "$REPO_DIR"

# ── 4. Back up /etc files that nix-darwin will manage ────────────────────────
for f in /etc/zshrc /etc/zprofile /etc/bashrc; do
  if [[ -f "$f" && ! -L "$f" ]]; then
    step "Backing up $f → ${f}.before-nix-darwin"
    sudo mv "$f" "${f}.before-nix-darwin" 2>/dev/null || warn "Could not back up $f (continuing)"
  fi
done

# ── 5. Bootstrap nix-darwin (first-time only) ─────────────────────────────────
if ! command -v darwin-rebuild &>/dev/null; then
  step "Bootstrapping nix-darwin for host '$TARGET_HOST'…"
  sudo nix run nix-darwin -- switch --flake "$REPO_DIR#$TARGET_HOST"
else
  step "Running darwin-rebuild switch for host '$TARGET_HOST'…"
  sudo darwin-rebuild switch --flake "$REPO_DIR#$TARGET_HOST"
fi

ok "Done! Open a new shell or run:  exec \$SHELL -l"
echo ""
echo "  Useful commands:"
echo "    make          → re-apply config changes"
echo "    make update   → update flake inputs"
echo "    make gc       → clean up old nix store"
