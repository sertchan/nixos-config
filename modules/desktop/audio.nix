{
  security.rtkit.enable = true; # Realtime scheduling for Pipewire
  services.pipewire = {
    # Required for audio and screen sharing
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
}
