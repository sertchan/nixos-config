{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  dev = config.modules.device;
in {
  config = mkIf dev.hasSound {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
  };
}
