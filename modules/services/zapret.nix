{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.lists) concatMap;
  inherit (lib.meta) getExe';
  inherit (lib.modules) mkForce;

  user = config.users.users.zapret.name;
  group = config.users.groups.zapret.name;

  iface = config.modules.device.wirelessInterface;
  mark = "0x40000000";
  qnum = toString config.services.zapret.qnum;

  stateDir = "/var/lib/zapret";
  autoHostlist = "${stateDir}/zapret-hosts-auto.txt";
  excludeHostlist = "${stateDir}/zapret-hosts-exclude.txt";
  autoHostlistDebugLog = "${stateDir}/zapret-hosts-auto-debug.log";
in {
  environment.systemPackages = [config.services.zapret.package];

  networking.networkmanager = {
    wifi = {
      macAddress = "permanent";
      scanRandMacAddress = false;
    };
    ethernet.macAddress = "permanent";
  };

  boot.kernel.sysctl = {"net.netfilter.nf_conntrack_tcp_be_liberal" = 1;};

  users = {
    users.zapret = {
      isSystemUser = true;
      inherit group;
      description = "zapret nfqws privilege-drop user";
      shell = getExe' pkgs.shadow "nologin";
    };
    groups.zapret = {};
  };

  networking.nftables = {
    enable = true;
    tables.zapret-raw = {
      family = "inet";
      content = ''
        chain output {
          type filter hook output priority raw; policy accept;
          meta mark and ${mark} == ${mark} counter notrack
        }
      '';
    };

    tables.zapret = {
      family = "inet";
      content = ''
        chain ingress {
          type filter hook prerouting priority -150; policy accept;
          iifname "${iface}" tcp sport { 80, 443 } ct reply packets 1-3 \
            counter queue num ${qnum} bypass
        }

        chain outbound {
          type filter hook output priority -10; policy accept;
          oifname "${iface}" tcp dport { 80, 443 } ct original packets 1-9 \
            meta mark and ${mark} != ${mark} counter queue num ${qnum} bypass
          oifname "${iface}" udp dport 443 ct original packets 1-9 \
            meta mark and ${mark} != ${mark} counter queue num ${qnum} bypass
        }
      '';
    };
  };

  services.zapret = {
    enable = true;
    params = [
      "--dpi-desync=fake"
      "--dpi-desync-autottl"
      "--dpi-desync-ttl=3"
      "--dpi-desync-fwmark=${mark}"
      "--hostlist-exclude=${excludeHostlist}"
      "--hostlist-auto=${autoHostlist}"
      "--hostlist-auto-fail-threshold=3"
      "--hostlist-auto-fail-time=180"
      "--hostlist-auto-debug=${autoHostlistDebugLog}"
    ];
    configureFirewall = false;
  };

  systemd = {
    services.zapret = {
      serviceConfig = {
        DynamicUser = false;
        User = user;
        Group = group;
        ReadWritePaths = [stateDir];
        RuntimeMaxSec = mkForce "6h";
        ExecStartPre = [
          "+${getExe' pkgs.coreutils "touch"} /run/nfqws.pid"
          "+${getExe' pkgs.coreutils "chown"} ${user}:${group} /run/nfqws.pid"
        ];
        CapabilityBoundingSet = [
          "CAP_NET_ADMIN"
          "CAP_NET_RAW"
        ];
        AmbientCapabilities = [
          "CAP_NET_ADMIN"
          "CAP_NET_RAW"
        ];
        NoNewPrivileges = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectKernelLogs = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
        UMask = "0077";
        PrivateDevices = true;
        ProcSubset = "pid";
        SystemCallFilter = ["@system-service"];
        SystemCallErrorNumber = "EPERM";
      };
      after = ["systemd-tmpfiles-setup.service"];
      wants = ["systemd-tmpfiles-setup.service"];
    };

    tmpfiles.rules =
      ["d ${stateDir} 0700 ${user} ${group} -"]
      ++ concatMap (path: [
        "f ${path} 0600 ${user} ${group} -"
        "z ${path} 0600 ${user} ${group} -"
      ]) [
        autoHostlist
        excludeHostlist
        autoHostlistDebugLog
      ];
  };
}
