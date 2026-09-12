{
  config,
  lib,
  options,
  pkgs,
  ...
}: let
  inherit (lib.attrsets) attrValues genAttrs;
  inherit (lib.meta) getExe';
  inherit (lib.modules) mkForce mkIf mkMerge;

  cfg = config.services.zapret2;
  dev = config.modules.device;
  settings = import ./settings.nix {inherit config lib;};

  user = config.users.users.zapret.name;
  group = config.users.groups.zapret.name;

  autoHostlistFiles =
    map (profile: profile.hosts.autodetect.file)
    (builtins.filter
      (profile: profile.hosts.autodetect.enable)
      (attrValues cfg.profiles));
in {
  config = mkMerge [
    {services.zapret2.enable = true;}
    (mkIf cfg.enable {
      environment.systemPackages = [cfg.package];

      users = {
        users.zapret = {
          isSystemUser = true;
          inherit group;
          description = "zapret2 service user";
          shell = getExe' pkgs.shadow "nologin";
        };
        groups.zapret = {};
      };

      networking.nftables.enable = true;

      services.zapret2 = {
        files = options.services.zapret2.files.default ++ [settings.strategy];
        firewall = {
          interfaces = [dev.wirelessInterface];
          tcpPorts = [80 443];
          udpPorts = [];
        };
        extraOptions = [
          "--hostlist-auto-debug=${settings.autoHostlistDebugLog}"
        ];
      };

      systemd = {
        services."nfqws2@default".serviceConfig =
          settings.hardening
          // {
            User = user;
            Group = group;
            DynamicUser = mkForce false;
            StateDirectory = mkForce settings.stateDirectory;
            StateDirectoryMode = "0700";
          };

        tmpfiles.settings.zapret =
          genAttrs [settings.stateDir settings.autoHostlistDir] (_: {
            d = {
              inherit user group;
              mode = "0700";
            };
          })
          // genAttrs ([settings.autoHostlistDebugLog] ++ autoHostlistFiles) (_: {
            f = {
              inherit user group;
              mode = "0600";
            };
          });
      };
    })
  ];
}
