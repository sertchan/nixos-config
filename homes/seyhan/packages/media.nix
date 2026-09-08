{pkgs, ...}: {
  home.packages = with pkgs; [
    ffmpeg_7-full
    ffmpegthumbnailer
    ffsubsync
    imagemagick
    losslesscut
    pulsemixer
    ueberzugpp
    waifu2x-converter-cpp
  ];
}
