{inputs}: let
  inherit (inputs.nixpkgs.lib) nixosSystem;

  modulePath = ../modules;
  deviceOptions = modulePath + /options/device.nix;
  systemOptions = modulePath + /options/system.nix;
  styleOptions = modulePath + /options/style.nix;
  core = modulePath + /core;
  desktop = modulePath + /desktop;

  bluetooth = modulePath + /hardware/bluetooth.nix;
  intelGpu = modulePath + /hardware/intel-gpu.nix;

  coredump = modulePath + /services/coredump.nix;
  dnsContentBlocking = modulePath + /services/dns-content-blocking.nix;
  wireshark = modulePath + /services/wireshark.nix;
  zapret = modulePath + /services/zapret.nix;

  homeManager = inputs.home-manager.nixosModules.home-manager;
  homes = ../homes;
in {
  arda-nirvana = nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit inputs;};
    modules = [
      deviceOptions
      systemOptions
      styleOptions

      homeManager
      homes

      core
      desktop

      bluetooth
      intelGpu

      coredump
      dnsContentBlocking
      wireshark
      zapret

      ./arda-nirvana
    ];
  };
}
