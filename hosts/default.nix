{inputs}: let
  inherit (inputs.nixpkgs.lib) nixosSystem;

  modulePath = ../modules;
  deviceOptions = modulePath + /options/device.nix;
  core = modulePath + /core;
  desktop = modulePath + /desktop;

  bluetooth = modulePath + /hardware/bluetooth.nix;
  intelGpu = modulePath + /hardware/intel-gpu.nix;

  dnsContentBlocking = modulePath + /services/dns-content-blocking.nix;
  wifiGateway = modulePath + /services/wifi-gateway.nix;
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

      homeManager
      homes

      core
      desktop

      bluetooth
      intelGpu

      dnsContentBlocking
      wifiGateway
      wireshark
      zapret

      ./arda-nirvana
    ];
  };
}
