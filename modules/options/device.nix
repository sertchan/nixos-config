{lib, ...}: let
  inherit (lib.modules) mkRemovedOptionModule;
  inherit (lib.options) mkOption;
  inherit (lib.types) bool nullOr str;
in {
  imports = [
    (mkRemovedOptionModule ["modules" "device" "type"] ''
      Removed, because nothing read it. Use the exact fact a module needs,
      such as modules.device.hasBluetooth, and declare a new one next to the
      module that reads it
    '')
  ];

  options.modules.device = {
    hasBluetooth = mkOption {
      type = bool;
      default = false;
      description = ''
        Whether the machine has a bluetooth radio

        This describes the hardware only. Set modules.system.bluetooth.enable
        to run the stack
      '';
    };

    hasSound = mkOption {
      type = bool;
      default = true;
      description = ''
        Whether the machine has an audio device

        True by default, because almost every machine has one. Set
        modules.system.audio.enable to run pipewire on it
      '';
    };

    wirelessInterface = mkOption {
      type = str;
      example = "wlp0s20f3";
      description = ''
        Name of the wireless interface under
        networking.usePredictableInterfaceNames

        The name comes from where the card sits on the bus, so it survives a
        reboot. DPI bypass rules and the bar both read it. It has no default,
        so a host that leaves it out fails to evaluate
      '';
    };

    wiredInterface = mkOption {
      type = nullOr str;
      default = null;
      example = "enp6s0";
      description = ''
        Name of the ethernet interface under
        networking.usePredictableInterfaceNames

        DPI bypass rules cover it as well as the wireless interface. A host
        with a port that leaves this unset has no protection over a cable.
        Use null on a machine with no ethernet port
      '';
    };
  };
}
