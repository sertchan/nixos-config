{ pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # VA-API driver for Intel Gen8+ and Xe integrated/discrete GPUs (iHD)
      vpl-gpu-rt # Intel oneVPL GPU runtime for QuickSync video encoding/decoding
      intel-compute-runtime # OpenCL (NEO) and Level Zero runtime for Intel Graphics
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Force VA-API hardware acceleration to use Intel iHD driver
  };
}
