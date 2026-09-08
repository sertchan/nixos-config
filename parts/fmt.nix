{pkgs}:
pkgs.writeShellApplication {
  name = "treefmt-nixos-config";
  runtimeInputs = [
    pkgs.treefmt
    pkgs.alejandra
    pkgs.git
  ];
  text = ''
    root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

    exec treefmt \
      --config-file ${../treefmt.toml} \
      --tree-root "$root" \
      --no-cache \
      "$@"
  '';
}
