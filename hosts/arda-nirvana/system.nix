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
      luks.devices.cryptroot.device = "/dev/disk/by-uuid/f85a37d0-02ef-497d-833d-2fb4288814ae";
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
