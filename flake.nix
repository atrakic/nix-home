{
  description = "nix-home — cross-platform (macOS + Linux) dev environment bootstrap";

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
      # ── Edit these to match your machines ──────────────────────────────
      user = "adtr";

      # macOS
      darwinHostname = "Admirs-MacBook-Pro-M1";
      darwinSystem = "aarch64-darwin"; # use "x86_64-darwin" for Intel Macs

      # Linux (NixOS) — change to match your box
      linuxHostname = "nix-dev-box";
      linuxSystem = "x86_64-linux"; # use "aarch64-linux" for ARM servers
      # ───────────────────────────────────────────────────────────────────

      # Systems that produce formatter / checks / devShells outputs
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      mkPreCommitCheck =
        system:
        pre-commit-hooks.lib.${system}.run {
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
      # ── macOS: `darwin-rebuild switch --flake .#<hostname>` ─────────────
      darwinConfigurations.${darwinHostname} = nix-darwin.lib.darwinSystem {
        system = darwinSystem;
        modules = [
          ./modules/darwin
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = import ./modules/home;
              extraSpecialArgs = { inherit user; };
            };
            # Define the user so home-manager's common module can resolve homeDirectory
            users.users.${user} = {
              home = "/Users/${user}";
              shell = nixpkgs.legacyPackages.${darwinSystem}.zsh;
            };
          }
        ];
      };

      # ── Linux (NixOS): `nixos-rebuild switch --flake .#<hostname>` ───────
      nixosConfigurations.${linuxHostname} = nixpkgs.lib.nixosSystem {
        system = linuxSystem;
        modules = [
          ./modules/linux
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = import ./modules/home;
              extraSpecialArgs = { inherit user; };
            };
            # Create the user account on NixOS
            users.users.${user} = {
              isNormalUser = true;
              shell = nixpkgs.legacyPackages.${linuxSystem}.zsh;
              extraGroups = [
                "wheel"
                "docker"
                "networkmanager"
              ];
            };
          }
        ];
      };

      # Convenience: `nix fmt` to format all .nix files
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      # Pre-commit hook checks (run via `nix flake check` or `make pre-commit`)
      checks = forAllSystems (system: {
        pre-commit-check = mkPreCommitCheck system;
      });

      # Quick dev shell for bootstrapping (`nix develop`)
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          pre-commit-check = mkPreCommitCheck system;
        in
        {
          default = pkgs.mkShell {
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
        }
      );
    };
}
