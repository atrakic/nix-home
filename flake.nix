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
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, ... }:
  let
    # ── Edit these to match your machine ───────────────────────────────
    user     = "adtr";
    hostname = "Admirs-MacBook-Pro-M1";
    system   = "aarch64-darwin";          # use "x86_64-darwin" for Intel Macs
    # ───────────────────────────────────────────────────────────────────

    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    # `darwin-rebuild switch --flake .` or `make apply`
    darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
      inherit system;
      modules = [
        ./modules/darwin

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs   = true;
          home-manager.useUserPackages = true;
          home-manager.users.${user}   = import ./modules/home;
          home-manager.extraSpecialArgs = { inherit user; };
        }
      ];
    };

    # Convenience: `nix fmt` to format all .nix files
    formatter.${system} = pkgs.nixfmt-rfc-style;

    # Quick dev shell for bootstrapping (`nix develop`)
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [ pkgs.nixfmt-rfc-style pkgs.nil pkgs.deadnix pkgs.statix ];
    };
  };
}
