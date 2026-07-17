{
  pkgs,
  lib,
  ...
}:
{
  boot = {
    loader = {
      systemd-boot.enable = lib.mkDefault true; # UEFI boot manager, replaces GRUB
      efi.canTouchEfiVariables = lib.mkDefault true;
    };
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest; # Always use the latest kernel
  };
}
