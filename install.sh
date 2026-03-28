#!/usr/bin/env bash
# -- install.sh ---------------------------------------------------------------
# Bootstrap a brand-new machine (macOS or Linux) with this flake.
# Run this ONCE on a fresh machine.
#
#   curl -fsSL https://raw.githubusercontent.com/atrakic/nix-home/main/install.sh | bash
#
# Or clone first:
#   git clone https://github.com/atrakic/nix-home ~/.config/nix-home
#   cd ~/.config/nix-home && bash install.sh
# -----------------------------------------------------------------------------
set -euo pipefail

REPO_DIR="${REPO_DIR:-$HOME/.config/nix-home}"
NIX_CONF="/etc/nix/nix.conf"
DETECTED_HOST="$(hostname -s 2>/dev/null || hostname 2>/dev/null || echo "unknown")"
TARGET_HOST="${TARGET_HOST:-${DETECTED_HOST%%.*}}"  # must match flake key
OS="$(uname -s)"
RUN_ID="$(date +%Y%m%d-%H%M%S)"

step() { echo "[STEP] $*"; }
ok()   { echo "[OK]   $*"; }
warn() { echo "[WARN] $*"; }
die()  { echo "[ERROR] $*" >&2; exit 1; }

require_cmd() {
  command -v "$1" &>/dev/null || die "Missing required command: $1"
}

preflight() {
  step "Running preflight checks for ${OS}..."

  case "${OS}" in
    Darwin|Linux) ;;
    *) die "Unsupported OS '$OS' (supported: Darwin, Linux)" ;;
  esac

  require_cmd curl
  require_cmd git
  require_cmd sudo

  # Prompt for sudo early so the rest of the flow is predictable.
  sudo -v || die "sudo is required for installation/activation"

  # Confirm installer and repo are reachable (fast fail on network/DNS issues).
  curl --proto '=https' --tlsv1.2 -fsSLI https://nixos.org/nix/install >/dev/null \
    || die "Cannot reach https://nixos.org/nix/install"
  curl --proto '=https' --tlsv1.2 -fsSLI https://github.com >/dev/null \
    || die "Cannot reach https://github.com"

  if [[ "${OS}" == "Darwin" ]] && ! xcode-select -p &>/dev/null; then
    die "Xcode Command Line Tools are required. Run: xcode-select --install"
  fi

  if [[ "${OS}" == "Linux" ]] && [[ ! -e /etc/NIXOS ]]; then
    warn "Non-NixOS Linux detected. This repo applies system config via nixos-rebuild."
    warn "Installer will continue, but final activation may not be applicable on this distro."
  fi

  ok "Preflight checks passed"
}

ensure_host_entry() {
  local file="$1"
  local attrset="$2"

  if [[ ! -f "$file" ]]; then
    die "Missing flake file: $file"
  fi

  if ! grep -Eq "\"${TARGET_HOST}\"[[:space:]]*=" "$file"; then
    die "Host '$TARGET_HOST' is not defined in $attrset inside flake.nix"
  fi
}

cleanup_stale_macos_nix_installer_backups() {
  # The official installer aborts if these backup files already exist.
  local f
  local moved=0
  for f in \
    /etc/bashrc.backup-before-nix \
    /etc/zshrc.backup-before-nix \
    /etc/bash.bashrc.backup-before-nix
  do
    if [[ -f "$f" ]]; then
      local archived="${f}.pre-install-${RUN_ID}"
      step "Archiving stale installer backup $f -> $archived"
      sudo mv "$f" "$archived"
      moved=1
    fi
  done

  if [[ "$moved" -eq 1 ]]; then
    ok "Archived stale nix installer backup files"
  fi
}

preflight

# -- 1. Install Nix (official installer) ---------------------------------------
if ! command -v nix &>/dev/null; then
  if [[ "${OS}" == "Darwin" ]]; then
    cleanup_stale_macos_nix_installer_backups
  fi

  step "Installing Nix via official installer (nixos.org)..."
  curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --daemon --yes
  # shellcheck disable=SC1091
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  ok "Nix installed: $(nix --version)"
else
  ok "Nix already installed: $(nix --version)"
fi

# Make sure nix-darwin binaries are reachable in non-login shells.
export PATH="/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH"

# -- 2. Enable flakes (just in case the installer didn't) ---------------------
if [[ -f "$NIX_CONF" ]] && ! grep -q "experimental-features" "$NIX_CONF"; then
  step "Enabling flakes in $NIX_CONF..."
  echo "experimental-features = nix-command flakes" | sudo tee -a "$NIX_CONF"
fi

# -- 3. Clone repo if needed ---------------------------------------------------
if [[ ! -d "$REPO_DIR" ]]; then
  step "Cloning nix-home to $REPO_DIR..."
  git clone https://github.com/atrakic/nix-home "$REPO_DIR"
else
  ok "Repo already present at $REPO_DIR"
fi

cd "$REPO_DIR"

# Ensure the current host key exists before attempting activation.
if [[ "$OS" == "Darwin" ]]; then
  ensure_host_entry "$REPO_DIR/flake.nix" "darwinHosts"
else
  ensure_host_entry "$REPO_DIR/flake.nix" "linuxHosts"
fi

# -- 4. Back up /etc files that nix-darwin will manage (macOS only) ----------
if [[ "$OS" == "Darwin" ]]; then
  for f in /etc/zshrc /etc/zprofile /etc/bashrc; do
    if [[ -f "$f" && ! -L "$f" ]]; then
      step "Backing up $f -> ${f}.before-nix-darwin"
      sudo mv "$f" "${f}.before-nix-darwin" 2>/dev/null || warn "Could not back up $f (continuing)"
    fi
  done
fi

# -- 5. Activate system config --------------------------------------------------
if [[ "$OS" == "Darwin" ]]; then
  if ! command -v darwin-rebuild &>/dev/null; then
    step "Bootstrapping nix-darwin for host '$TARGET_HOST'..."
    sudo nix run nix-darwin -- switch --flake "$REPO_DIR#$TARGET_HOST"
  else
    step "Running darwin-rebuild switch for host '$TARGET_HOST'..."
    sudo darwin-rebuild switch --flake "$REPO_DIR#$TARGET_HOST"
  fi
elif [[ "$OS" == "Linux" ]]; then
  if command -v nixos-rebuild &>/dev/null; then
    step "Running nixos-rebuild switch for host '$TARGET_HOST'..."
    sudo nixos-rebuild switch --flake "$REPO_DIR#$TARGET_HOST"
  else
    step "Running nixos-rebuild via nix run for host '$TARGET_HOST'..."
    sudo nix run nixpkgs#nixos-rebuild -- switch --flake "$REPO_DIR#$TARGET_HOST"
  fi
fi

ok "Done! Open a new shell or run:  exec \$SHELL -l"
echo ""
echo "  Useful commands:"
echo "    make          -> re-apply config changes"
echo "    make update   -> update flake inputs"
echo "    make gc       -> clean up old nix store"
