{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.strings) concatStringsSep optionalString;

  cfg = config.modules.services.zapret;
  zapret2 = config.services.zapret2;
  shared = import ./shared.nix {inherit config lib;};
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
      ${getExe zapret2.package} --intercept=0 \
      ${concatStringsSep " " shared.luaInit} \
      --lua-init=@${shared.strategyTest}
    touch "$out"
  '';
}
