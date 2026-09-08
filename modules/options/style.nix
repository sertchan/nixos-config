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
        The colours more than one program draws with, as #rrggbb.

        A program keeps a shade of its own where it is the only one using it,
        such as the terminal palette. Everything a second program repeats
        belongs here, so a change to the look is a change to one attribute.
      '';
    };

    gtkColorDefinitions = mkOption {
      type = str;
      default = concatStrings (mapAttrsToList (name: value: "@define-color ${name} ${value};\n") cfg.colors);
      defaultText = "one @define-color line per entry in modules.style.colors";
      readOnly = true;
      description = ''
        The palette in the form a GTK3 stylesheet reads it back as @name.

        CSS custom properties arrived in GTK 4.16, so a GTK3 sheet that names
        one parses nothing and fails without a message. waybar and wofi both
        render through GTK3, which leaves @define-color as the mechanism.
      '';
    };
  };
}
