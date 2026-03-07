{
  description = "nix-home — macOS bootstrap for a data/fullstack/architect dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nix-darwin,
      home-manager,
      pre-commit-hooks,
      ...
    }:
    let
      # ── Edit these to match your machine ───────────────────────────────
      user = "adtr";
      hostname = "Admirs-MacBook-Pro-M1";
      system = "aarch64-darwin"; # use "x86_64-darwin" for Intel Macs
      # ───────────────────────────────────────────────────────────────────

      pkgs = nixpkgs.legacyPackages.${system};

      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          # ── Nix ──────────────────────────────────────────────────────
          nixfmt.enable = true; # format
          statix.enable = true; # anti-patterns
          deadnix.enable = true; # unused bindings

          # ── Flake check (runs `nix flake check --no-build`) ───────────
          nix-flake-check = {
            enable = true;
            name = "nix flake check";
            entry = "nix flake check --no-build";
            pass_filenames = false;
            language = "system";
          };

          # ── Shell scripts ─────────────────────────────────────────────
          shellcheck.enable = true;
          shfmt.enable = true;
        };
      };
    in
    {
      # `darwin-rebuild switch --flake .` or `make apply`
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          ./modules/darwin

          home-manager.darwinModules.home-manager
          {
            users.users.${user} = {
              home = "/Users/${user}";
            };

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = import ./modules/home;
              extraSpecialArgs = { inherit user; };
            };
          }
        ];
      };

      # Convenience: `nix fmt` to format all .nix files
      formatter.${system} = pkgs.nixfmt;

      # Pre-commit hook checks (run via `nix flake check` or `make pre-commit`)
      checks.${system} = { inherit pre-commit-check; };

      # Quick dev shell for bootstrapping (`nix develop`)
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.nixfmt
          pkgs.nil
          pkgs.deadnix
          pkgs.statix
          pkgs.pre-commit
        ]
        ++ pre-commit-check.enabledPackages;
        # Install hooks automatically when entering `nix develop`
        inherit (pre-commit-check) shellHook;
      };
    };
}
