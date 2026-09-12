{
  config,
  lib,
  options,
  pkgs,
  ...
}: let
  inherit (lib.attrsets) genAttrs;
  inherit (lib.lists) optional;
  inherit (lib.meta) getExe';
  inherit (lib.modules) mkForce mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.modules.services.zapret;
  zapret2 = config.services.zapret2;
  dev = config.modules.device;
  shared = import ./shared.nix {inherit config lib;};
in {
  options.modules.services.zapret.enable = mkEnableOption "the zapret2 DPI bypass";

  config = mkIf cfg.enable {
    environment.systemPackages = [zapret2.package];

    users = {
      users.zapret = {
        isSystemUser = true;
        inherit (shared) group;
        description = "zapret2 service user";
        shell = getExe' pkgs.shadow "nologin";
      };
      groups.zapret = {};
    };

    networking.nftables.enable = true;

    services.zapret2 = {
      enable = true;
      files = options.services.zapret2.files.default ++ [shared.strategy];
      firewall = {
        interfaces = [dev.wirelessInterface] ++ optional (dev.wiredInterface != null) dev.wiredInterface;
        tcpPorts = [80 443];
        udpPorts = [];
      };
      extraOptions = [
        "--hostlist-auto-debug=${shared.debugLog}"
      ];
    };

    systemd = {
      services."nfqws2@default".serviceConfig =
        shared.nfqwsHardening
        // {
          User = shared.user;
          Group = shared.group;
          DynamicUser = mkForce false;
          StateDirectory = mkForce shared.stateDirectory;
          StateDirectoryMode = "0700";
        };

      tmpfiles.settings.zapret =
        genAttrs [shared.stateDir shared.networksDir shared.activityDir] (_: {
          d = {
            inherit (shared) user group;
            mode = "0700";
          };
        })
        // {
          ${shared.currentDir}.L = {
            inherit (shared) user group;
            argument = "networks/${shared.offlineNetwork}";
          };
        };
    };
  };
}
