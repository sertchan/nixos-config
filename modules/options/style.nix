{
  config,
  lib,
  ...
}: let
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.options) mkOption;
  inherit (lib.strings) concatStrings;
  inherit (lib.types) attrsOf str;

  cfg = config.modules.style;
in {
  options.modules.style = {
    colors = mkOption {
      type = attrsOf str;
      default = {
        base = "#0f0f0f";
        foreground = "#ffffff";
        good = "#00ff00";
        warning = "#ffff00";
        critical = "#ff0000";
      };
      description = ''
        Colours that more than one program draws with, written as #rrggbb

        A program keeps its own shade while it is the only user, such as the
        terminal palette. A colour moves here once a second program needs it,
        so changing the look means changing one attribute
      '';
    };

    gtkColorDefinitions = mkOption {
      type = str;
      default = concatStrings (mapAttrsToList (name: value: "@define-color ${name} ${value};\n") cfg.colors);
      defaultText = "one @define-color line per entry in modules.style.colors";
      readOnly = true;
      description = ''
        The palette in the form GTK3 reads, where each colour becomes @name

        GTK gained CSS custom properties in 4.16. A GTK3 sheet that uses one
        parses nothing and fails without a message. waybar and wofi both draw
        through GTK3, so @define-color is what works here
      '';
    };
  };
}
