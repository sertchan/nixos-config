{pkgs}:
pkgs.writeShellApplication {
  name = "nixos-config-pre-commit";
  runtimeInputs = [
    pkgs.git
    pkgs.alejandra
    pkgs.statix
    pkgs.deadnix
  ];
  text = ''
    root=$(git rev-parse --show-toplevel)
    cd "$root"

    mapfile -t staged < <(git diff --cached --name-only --diff-filter=ACMR -- '*.nix')

    if [ ''${#staged[@]} -eq 0 ]; then
      exit 0
    fi

    fail=0

    alejandra --check "''${staged[@]}" || fail=1

    statix check . || fail=1

    deadnix --fail "''${staged[@]}" || fail=1

    if [ "$fail" -ne 0 ]; then
      echo
      echo "pre-commit failed. Run 'nix fmt' and fix the reports above, then stage again."
      exit 1
    fi
  '';
}
