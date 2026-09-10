{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.attrsets) genAttrs;
  inherit (lib.meta) getExe';
  inherit (lib.modules) mkForce;
  inherit (lib.strings) concatStringsSep;

  cfg = config.services.zapret2;
  dev = config.modules.device;

  user = config.users.users.zapret.name;
  group = config.users.groups.zapret.name;

  stateDirectory = "zapret";
  stateDir = "/var/lib/${stateDirectory}";
  autoHostlist = "${stateDir}/zapret-hosts-auto.txt";
  excludeHostlist = "${stateDir}/zapret-hosts-exclude.txt";
  autoHostlistDebugLog = "${stateDir}/zapret-hosts-auto-debug.log";

  fakeTtlFallback = toString 3;
  fakeAutoTtl = "-1,3-20";
  fakeTtlOptions = concatStringsSep ":" [
    "ip_ttl=${fakeTtlFallback}"
    "ip6_ttl=${fakeTtlFallback}"
    "ip_autottl=${fakeAutoTtl}"
    "ip6_autottl=${fakeAutoTtl}"
  ];
  autoHostlistFailureWindow = toString 180;
  initialPacketsToInspect = 9;

  mkProfile = parameters: {
    hosts.autodetect = {
      enable = true;
      file = autoHostlist;
    };
    parameters =
      [
        "--hostlist-exclude=${excludeHostlist}"
        "--hostlist-auto-fail-time=${autoHostlistFailureWindow}"
      ]
      ++ parameters;
  };
in {
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
    enable = true;
    firewall = {
      interfaces = [dev.wirelessInterface];
      tcpPorts = [80 443];
      udpPorts = [443];
      maxPackets = initialPacketsToInspect;
    };

    profiles = {
      http = mkProfile [
        "--filter-tcp=80"
        "--payload=http_req"
        "--lua-desync=fake:blob=fake_default_http:${fakeTtlOptions}"
      ];
      https = mkProfile [
        "--filter-tcp=443"
        "--payload=tls_client_hello"
        "--lua-desync=fake:blob=fake_default_tls:tls_mod=rnd,rndsni,dupsid:${fakeTtlOptions}"
      ];
      quic = mkProfile [
        "--filter-udp=443"
        "--payload=quic_initial"
        "--lua-desync=fake:blob=fake_default_quic:${fakeTtlOptions}"
      ];
    };

    extraOptions = [
      "--hostlist-auto-debug=${autoHostlistDebugLog}"
    ];
  };

  systemd = {
    services."nfqws2@default" = {
      serviceConfig = {
        User = user;
        Group = group;
        DynamicUser = mkForce false;
        StateDirectory = mkForce stateDirectory;
        StateDirectoryMode = "0700";
        RuntimeMaxSec = "6h";
        ProtectSystem = mkForce "strict";
        DevicePolicy = "closed";
        KeyringMode = "private";
        SystemCallErrorNumber = "EPERM";
      };
    };

    tmpfiles.settings.zapret =
      {
        ${stateDir}.d = {
          inherit user group;
          mode = "0700";
        };
      }
      // genAttrs [
        autoHostlist
        excludeHostlist
        autoHostlistDebugLog
      ] (_: {
        f = {
          inherit user group;
          mode = "0600";
        };
      });
  };
}
