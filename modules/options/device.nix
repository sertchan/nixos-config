{lib, ...}: let
  inherit (lib.options) mkOption;
  inherit (lib.types) bool enum;
in {
  options.modules.device = {
    type = mkOption {
      type = enum ["laptop" "desktop"];
      description = ''
        What the machine physically is.

        Read by both trees. The system side uses it for power and firmware
        decisions, the user side uses it to leave out anything a desktop has no
        use for. There is no default on purpose. A host that does not state it fails
        evaluation with the module system saying so, which beats guessing.
      '';
    };

    hasBluetooth = mkOption {
      type = bool;
      default = false;
      description = ''
        Whether the machine has a bluetooth radio.

        This is a fact about the hardware and not a request to run anything. The
        stack is still turned on separately, because owning the radio is not a
        reason to leave it listening.
      '';
    };

    hasSound = mkOption {
      type = bool;
      default = true;
      description = ''
        Whether the machine has an audio device worth configuring.

        Defaults to true because everything with a screen has one. A headless
        host sets it false and drops the whole audio stack with it.
      '';
    };
  };
}
