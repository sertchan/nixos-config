{ pkgs, ... }:
{
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs # Wayland wlroots screen capture plugin
      obs-vaapi # VA-API hardware-accelerated video encoding plugin
      obs-pipewire-audio-capture # Per-application PipeWire audio source capture
      obs-vkcapture # Vulkan/OpenGL direct game capture plugin
    ];
  };
}
