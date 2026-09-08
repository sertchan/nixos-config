{
  pkgs,
  self,
}: let
  mkCheck = name: nativeBuildInputs: script:
    pkgs.runCommand "check-${name}" {inherit nativeBuildInputs;} ''
      ${script}
      touch $out
    '';
in {
  formatting = mkCheck "formatting" [pkgs.alejandra] "alejandra --check ${self}";
  lint = mkCheck "lint" [pkgs.statix] "statix check ${self}";
  dead-code = mkCheck "dead-code" [pkgs.deadnix] "deadnix --fail ${self}";
}
