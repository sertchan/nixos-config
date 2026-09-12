{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.strings) optionalString;

  cfg = config.services.zapret2;
  settings = import ./settings.nix {inherit config lib;};
  firewallRules = pkgs.writeText "zapret-test.nft" ''
    table inet zapret2 {
      ${config.networking.nftables.tables.zapret2.content}
    }
  '';
in {
  system.build.zapretStrategyTest = pkgs.runCommand "zapret-strategy-test" {nativeBuildInputs = [pkgs.util-linux pkgs.nftables];} ''
    ${optionalString cfg.enable ''
      unshare --user --map-current-user --net --keep-caps nft --check --file ${firewallRules}
    ''}
    unshare --user --map-current-user --net --keep-caps \
      setpriv --bounding-set=-setuid,-setgid --inh-caps=-setuid,-setgid --ambient-caps=-setuid,-setgid \
      ${getExe cfg.package} --intercept=0 \
      --lua-init=@${cfg.package}/share/zapret2/lua/zapret-lib.lua \
      --lua-init=@${cfg.package}/share/zapret2/lua/zapret-antidpi.lua \
      --lua-init=@${settings.strategy} \
      --lua-init=@${./strategy-test.lua}
    touch "$out"
  '';
}
