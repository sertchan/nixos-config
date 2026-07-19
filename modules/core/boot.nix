{
  pkgs,
  lib,
  ...
}:
{
  boot = {
    loader = {
      # UEFI boot manager, replacing legacy GRUB
      systemd-boot.enable = lib.mkDefault true;
      efi.canTouchEfiVariables = lib.mkDefault true;
    };
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  };
}
