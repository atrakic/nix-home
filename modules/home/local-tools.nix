_: {
  # ── ~/bin — personal scripts managed by home-manager ─────────────────
  # Files here are symlinked from the Nix store; make them executable via
  # the `executable = true` attribute.

  home.file = {

    # ── localhost.run tunnel ──────────────────────────────────────────
    # Expose a local port via the free localhost.run SSH tunnel service.
    # Usage: ~/bin/localhost.run.sh [PORT]   (default: 8080)
    "bin/localhost.run.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # localhost.run — expose a local port over an SSH reverse tunnel
        # https://localhost.run/docs/
        set -euo pipefail

        PORT="''${1:-8080}"
        REMOTE_HOST="ssh.localhost.run"
        KEY="''${LOCALHOST_RUN_KEY:-}"   # optional: path to a dedicated SSH key

        usage() {
          echo "Usage: $(basename "$0") [PORT]"
          echo "  Tunnels localhost:PORT to a public localhost.run URL."
          echo "  Set LOCALHOST_RUN_KEY env var to use a custom SSH key."
          exit 1
        }

        [[ "''${1:-}" == "-h" || "''${1:-}" == "--help" ]] && usage

        SSH_OPTS=(
          -o StrictHostKeyChecking=no
          -o ServerAliveInterval=30
          -o ServerAliveCountMax=3
          -R "80:localhost:''${PORT}"
        )

        if [[ -n "''${KEY}" ]]; then
          SSH_OPTS+=(-i "''${KEY}")
        fi

        echo "→ Tunnelling localhost:''${PORT} via ''${REMOTE_HOST} …"
        echo "  (Press Ctrl-C to stop)"
        echo ""

        exec ssh "''${SSH_OPTS[@]}" "''${REMOTE_HOST}"
      '';
    };

  };
}
