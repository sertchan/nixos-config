{
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) readDir;
  inherit (lib.attrsets) attrNames filterAttrs;
  inherit (lib.lists) any;
  inherit (lib.meta) getExe getExe';
  inherit (lib.strings) concatStringsSep hasSuffix toLower;

  imageSuffixes = [".jpg" ".jpeg" ".png" ".webp"];

  isImage = name: any (suffix: hasSuffix suffix (toLower name)) imageSuffixes;

  images = filterAttrs (name: type: type == "regular" && isImage name) (readDir ./.);

  wallpapers = map (name: "${./. + "/${name}"}") (attrNames images);

  wallpaperDaemon =
    pkgs.runCommandLocal "wallpaper-daemon" {
      nativeBuildInputs = [pkgs.gcc pkgs.rustc];

      AWWW = getExe pkgs.awww;
      AWWW_DAEMON = getExe' pkgs.awww "awww-daemon";
      WALLPAPERS = concatStringsSep "\n" wallpapers;
    } ''
      mkdir -p $out/bin
      rustc -O -C strip=symbols --edition 2021 -o $out/bin/wallpaper-daemon ${./main.rs}
    '';
in {
  assertions = [
    {
      assertion = wallpapers != [];
      message = "homes/seyhan/desktop/wallpapers holds no image. Add a jpg, jpeg, png or webp file beside its default.nix";
    }
  ];

  home.packages = [wallpaperDaemon];
}
