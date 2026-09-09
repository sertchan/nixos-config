{
  lib,
  osConfig,
  pkgs,
  ...
}: let
  inherit (lib.generators) toLua;
  inherit (lib.lists) zipListsWith;
  inherit (lib.strings) concatMapStrings fixedWidthString substring toLower;
  inherit (lib.trivial) fromHexString toHexString;

  inherit (osConfig.modules.style) colors;

  channelOffsets = [1 3 5];

  channelsOf = hex: map (offset: fromHexString (substring offset 2 hex)) channelOffsets;

  hexOf = channels: "#" + concatMapStrings (channel: toLower (fixedWidthString 2 "0" (toHexString channel))) channels;

  opaqueBlend = percent: over: under:
    hexOf (zipListsWith
      (front: back: (percent * front + (100 - percent) * back + 50) / 100)
      (channelsOf over)
      (channelsOf under));

  hairline = opaqueBlend 8 colors.foreground colors.base;
  explorerCard = opaqueBlend 4 colors.foreground colors.base;

  paletteModule = pkgs.writeTextFile {
    name = "nvim-palette";
    destination = "/lua/palette.lua";
    text = "return ${toLua {} (colors // {inherit hairline explorerCard;})}\n";
  };
in {
  xdg.configFile."nvim/lua".source = pkgs.symlinkJoin {
    name = "nvim-lua";
    paths = [./lua "${paletteModule}/lua"];
  };
}
