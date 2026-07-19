{
  config,
  lib,
  modulesPath,
  ...
}:
{
  # Default hardware scan imports
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

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
    kernelModules = [ "kvm-intel" ]; # Intel CPU virtualization
    kernelParams = [ "mem_sleep_default=deep" ]; # Force deep sleep (S3 suspend state)
    extraModulePackages = [ ];
    tmp.useTmpfs = true; # Mount /tmp in RAM
  };

  # Enable zram compressed swap space in RAM
  zramSwap.enable = true;

  fileSystems = {
    # Root partition
    "/" = {
      device = "/dev/disk/by-label/NIXROOT";
      fsType = "ext4";
    };

    # EFI system partition
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

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
