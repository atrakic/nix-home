{
  description = "nix-home - cross-platform (macOS + Linux) dev environment bootstrap";

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
      # -- Machine registry -----------------------------------------------
      # Add your machines here.  The Makefile selects the matching config
      # via `--flake .#$(hostname -s)`, so the key MUST equal `hostname -s`.
      darwinHosts = {
        "Admirs-MacBook-Pro-M1" = {
          system = "aarch64-darwin";
          user = "adtr";
        };
        "Admirs-MacBook-Air" = {
          system = "aarch64-darwin";
          user = "atrakic";
        };
        # "My-Intel-Mac" = { system = "x86_64-darwin"; user = "someone"; };
      };

      linuxHosts = {
        "nix-dev-box" = {
          system = "x86_64-linux";
          user = "adtr";
        };
        # "arm-server" = { system = "aarch64-linux"; user = "admin"; };
      };
      # -------------------------------------------------------------------

      # Systems that produce formatter / checks / devShells outputs
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # -- Host builders --------------------------------------------------
      mkDarwinHost =
        name: { system, user }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          modules = [
            ./modules/darwin
            home-manager.darwinModules.home-manager
            {
              system.primaryUser = user;
              nixpkgs.config.allowUnfree = true;

              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${user} = import ./modules/home;
                extraSpecialArgs = { inherit user; };
              };
              users.users.${user} = {
                home = "/Users/${user}";
                shell = nixpkgs.legacyPackages.${system}.zsh;
              };
            }
          ];
        };

      mkNixosHost =
        name: { system, user }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./modules/linux
            home-manager.nixosModules.home-manager
            {
              nixpkgs.config.allowUnfree = true;

              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${user} = import ./modules/home;
                extraSpecialArgs = { inherit user; };
              };
              users.users.${user} = {
                isNormalUser = true;
                shell = nixpkgs.legacyPackages.${system}.zsh;
                extraGroups = [
                  "wheel"
                  "docker"
                  "networkmanager"
                ];
              };
            }
          ];
        };

      mkPreCommitCheck =
        system:
        pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            # -- Nix ------------------------------------------------------
            nixfmt.enable = true; # format
            statix.enable = true; # anti-patterns
            deadnix.enable = true; # unused bindings

            # -- Flake check (runs `nix flake check --no-build`) -----------
            nix-flake-check = {
              enable = true;
              name = "nix flake check";
              entry = "nix flake check --no-build";
              pass_filenames = false;
              language = "system";
            };

            # -- Shell scripts ---------------------------------------------
            shellcheck.enable = true;
            shfmt.enable = true;
          };
        };
    in
    {
      # -- macOS: `darwin-rebuild switch --flake .#<hostname>` -------------
      darwinConfigurations = builtins.mapAttrs mkDarwinHost darwinHosts;

      # -- Linux (NixOS): `nixos-rebuild switch --flake .#<hostname>` -------
      nixosConfigurations = builtins.mapAttrs mkNixosHost linuxHosts;

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
