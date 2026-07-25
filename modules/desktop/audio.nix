{
  security.rtkit.enable = true; # RealtimeKit daemon for high-priority audio processing threads

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # 32-bit ALSA emulation for 32-bit applications and games
    pulse.enable = true; # PulseAudio server emulation layer for legacy clients
    wireplumber.enable = true; # Modular session manager for PipeWire
  };
}
