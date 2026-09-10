{
  config,
  lib,
  modulesPath,
  ...
}: let
  inherit (lib.modules) mkDefault;
in {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "rtsx_usb_sdmmc"
      ];
      kernelModules = [];
      luks.devices.cryptroot.device = "/dev/disk/by-partuuid/bed9db3c-9a06-499d-be84-c81a27aaa911";
    };
    kernelModules = ["kvm-intel"];
    kernelParams = ["mem_sleep_default=deep"];
    extraModulePackages = [];
    tmp.useTmpfs = true;
  };

  zramSwap.enable = true;

  fileSystems = {
    "/" = {
      device = "/dev/mapper/cryptroot";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/NIXBOOT";
      fsType = "vfat";
    };
  };

  networking.useDHCP = mkDefault true;
  nixpkgs.hostPlatform = mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;
}
