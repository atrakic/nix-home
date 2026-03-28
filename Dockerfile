# Test image - runs lint/check targets inside a Nix container (Linux).
# nix-darwin & Homebrew are macOS-only and are NOT tested here.
# What IS tested: flake evaluation, nixfmt, statix, deadnix.
FROM nixos/nix:latest

# Enable flakes + disable sandbox (required inside Docker)
RUN mkdir -p /etc/nix && printf '%s\n' \
      'experimental-features = nix-command flakes' \
      'sandbox = false' \
      'accept-flake-config = true' \
    >> /etc/nix/nix.conf

# Trust any mounted workspace regardless of UID (fixes git ownership check)
RUN git config --global --add safe.directory '*'

# Install make and other useful shell tools
RUN nix-env -iA nixpkgs.gnumake nixpkgs.bash

WORKDIR /workspace
COPY . .

# Pre-populate the Nix store so the container is self-contained
RUN nix flake check --no-build 2>&1 || true   # warm cache even on expected darwin warnings
