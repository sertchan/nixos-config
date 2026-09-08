{lib, ...}: let
  inherit (lib.modules) mkRemovedOptionModule;
  inherit (lib.options) mkOption;
  inherit (lib.types) bool;
in {
  imports = [
    (mkRemovedOptionModule ["modules" "device" "type"] ''
      Removed, because nothing read it. Branch on the specific fact a module
      needs, such as modules.device.hasBluetooth, and declare a new one beside
      the module that reads it.
    '')
  ];

  options.modules.device = {
    hasBluetooth = mkOption {
      type = bool;
      default = false;
      description = ''
        Whether the machine has a bluetooth radio.

        This is a fact about the hardware and not a request to run anything.
        modules.system.bluetooth.enable starts the stack, because owning the
        radio is a separate question from leaving it listening.
      '';
    };

    hasSound = mkOption {
      type = bool;
      default = true;
      description = ''
        Whether the machine has an audio device worth configuring.

        Defaults to true because everything with a screen has one.
        modules.system.audio.enable starts pipewire on top of it.
      '';
    };
  };
}
