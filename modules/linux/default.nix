{ pkgs, ... }:
{
  # -- Hardware ---------------------------------------------------------
  # Replace these with your actual hardware-configuration.nix values.
  # Run `nixos-generate-config` on the target machine and paste the output.
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda"; # or "nodev" for EFI
  };
  # -- Nix settings ----------------------------------------------------
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      warn-dirty = false;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # -- Shell ------------------------------------------------------------
  programs.zsh.enable = true;

  environment.systemPackages = [ pkgs.vim ]; # bare minimum in PATH

  # -- System -----------------------------------------------------------
  # Allow unfree packages (VSCode, etc.)
  nixpkgs.config.allowUnfree = true;

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Stockholm";

  # -- SSH --------------------------------------------------------------
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  system.stateVersion = "24.05";
}
