{pkgs}: let
  preCommit = import ./pre-commit.nix {inherit pkgs;};
in
  pkgs.mkShellNoCC {
    name = "nixos-config";
    packages = [
      pkgs.alejandra
      pkgs.deadnix
      pkgs.statix
      pkgs.treefmt
      preCommit
    ];
    shellHook = ''
      gitDir=$(git rev-parse --git-dir 2>/dev/null || true)
      hookTarget="${preCommit}/bin/nixos-config-pre-commit"

      if [ -n "$gitDir" ] && [ "$(readlink "$gitDir/hooks/pre-commit" 2>/dev/null)" != "$hookTarget" ]; then
        mkdir -p "$gitDir/hooks"
        ln -sf "$hookTarget" "$gitDir/hooks/pre-commit"
        echo "installed pre-commit hook -> $hookTarget"
      fi
    '';
  }
