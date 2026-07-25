{
  config,
  lib,
  modulesPath,
  ...
}:
{
  # ----- Module Imports -----
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # ----- Boot Configuration -----
  boot = {
    initrd = {
      # Modules required to detect storage/USB devices during early boot stage
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "rtsx_usb_sdmmc"
      ];
      kernelModules = [ ];
    };

    kernelModules = [ "kvm-intel" ];
    kernelParams = [ "mem_sleep_default=deep" ]; # Force deep sleep (S3 suspend state)
    extraModulePackages = [ ];
    tmp.useTmpfs = true;
  };

  # ----- Storage & File Systems -----
  zramSwap.enable = true;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXROOT";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-label/NIXBOOT";
      fsType = "vfat";
    };

    # Screenshot folder in RAM to prevent redundant disk writes
    "/home/seyhan/Pictures/Screenshots" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [
        "noatime"
        "nodev"
        "nosuid"
        "size=128M"
        "uid=1000"
        "gid=100"
        "mode=0700"
      ];
    };
  };

  # ----- Hardware & Platform -----
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
