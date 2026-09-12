{
  config,
  lib,
  options,
  pkgs,
  ...
}: let
  inherit (builtins) filter;
  inherit (lib.attrsets) attrValues genAttrs;
  inherit (lib.meta) getExe';
  inherit (lib.modules) mkForce mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.modules.services.zapret;
  zapret2 = config.services.zapret2;
  dev = config.modules.device;
  settings = import ./settings.nix {inherit config lib;};

  user = config.users.users.zapret.name;
  group = config.users.groups.zapret.name;

  autoHostlistFiles =
    map (profile: profile.hosts.autodetect.file)
    (filter (profile: profile.hosts.autodetect.enable) (attrValues zapret2.profiles));
in {
  options.modules.services.zapret.enable = mkEnableOption "the zapret2 DPI bypass";

  config = mkIf cfg.enable {
    environment.systemPackages = [zapret2.package];

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

    services = {
      zapret2 = {
        enable = true;
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

      logrotate.settings.${settings.autoHostlistDebugLog} = {
        frequency = "daily";
        rotate = 7;
        maxsize = "8M";
        create = "0600 ${user} ${group}";
      };
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
  };
}
