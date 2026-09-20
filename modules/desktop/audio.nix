{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.modules.system.audio;
  dev = config.modules.device;
in {
  options.modules.system.audio.enable = mkEnableOption "the pipewire audio stack";

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = dev.hasSound;
        message = "${config.networking.hostName} enables the audio stack but has no audio device. Set modules.device.hasSound in the host configuration, or clear modules.system.audio.enable";
      }
    ];

    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
