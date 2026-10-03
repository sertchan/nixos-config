{
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) map path toString;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.lists) any;
  inherit (lib.meta) getExe getExe';
  inherit (lib.strings) concatStringsSep hasSuffix toLower;

  imageSuffixes = [".jpg" ".jpeg" ".png" ".webp"];

  isImage = name: any (suffix: hasSuffix suffix (toLower name)) imageSuffixes;

  wallpaperDirectory = path {
    path = ./.;
    name = "wallpapers";
    filter = name: type: type == "directory" || (type == "regular" && isImage name);
  };

  wallpapers = map toString (listFilesRecursive wallpaperDirectory);

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
      message = "homes/seyhan/desktop/wallpapers holds no image. Add a jpg, jpeg, png or webp file there or in a subfolder";
    }
  ];

  home.packages = [wallpaperDaemon];
}
