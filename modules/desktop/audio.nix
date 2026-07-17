{
  security.rtkit.enable = true; # Realtime scheduling for audio (pipewire)
  services.pipewire = {
    # Necessary for sound and screen sharing
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
}
