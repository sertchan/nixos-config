{
  pkgs,
  lib,
  ...
}:
{
  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    loader = {
      systemd-boot.enable = lib.mkDefault true;
      efi.canTouchEfiVariables = lib.mkDefault true; # Allow NixOS to modify EFI boot variables in NVRAM
    };
  };
}
