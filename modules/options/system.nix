{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.modules.system.bluetooth.enable = mkEnableOption "the bluetooth stack";
}
