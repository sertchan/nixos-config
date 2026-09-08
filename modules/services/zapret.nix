{
  config,
  lib,
  pkgs,
  ...
}: let
  iface = "wlp0s20f3";
  qnum = toString config.services.zapret.qnum;
in {
  environment.systemPackages = [pkgs.zapret];

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
      group = "zapret";
      description = "zapret nfqws privilege-drop user";
      shell = "${pkgs.shadow}/bin/nologin";
    };
    groups.zapret = {};
  };

  networking.nftables = {
    enable = true;
    tables.zapret = {
      family = "inet";
      content = ''
        chain inbound {
          type filter hook input priority -10; policy accept;
          iifname "${iface}" tcp sport { 80, 443 } ct reply packets 1-3 queue num ${qnum} bypass
        }

        chain outbound {
          type filter hook output priority -10; policy accept;
          oifname "${iface}" tcp dport { 80, 443 } ct original packets 1-9 queue num ${qnum} bypass
          oifname "${iface}" udp dport 443 ct original packets 1-9 queue num ${qnum} bypass
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
      "--hostlist-exclude=/var/lib/zapret/zapret-hosts-exclude.txt"
      "--hostlist-auto=/var/lib/zapret/zapret-hosts-auto.txt"
      "--hostlist-auto-fail-threshold=3"
      "--hostlist-auto-fail-time=180"
      "--hostlist-auto-debug=/var/lib/zapret/zapret-hosts-auto-debug.log"
    ];
    configureFirewall = false;
  };

  systemd = {
    services.zapret = {
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = lib.mkForce "zapret";
        Group = lib.mkForce "zapret";
        ReadWritePaths = ["/var/lib/zapret"];
        RuntimeMaxSec = lib.mkForce "6h";
        ExecStartPre = [
          "+${pkgs.coreutils}/bin/touch /run/nfqws.pid"
          "+${pkgs.coreutils}/bin/chown zapret:zapret /run/nfqws.pid"
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

    tmpfiles.rules = [
      "d /var/lib/zapret 0700 zapret zapret -"
      "f /var/lib/zapret/zapret-hosts-auto.txt 0600 zapret zapret -"
      "z /var/lib/zapret/zapret-hosts-auto.txt 0600 zapret zapret -"
      "f /var/lib/zapret/zapret-hosts-exclude.txt 0600 zapret zapret -"
      "z /var/lib/zapret/zapret-hosts-exclude.txt 0600 zapret zapret -"
      "f /var/lib/zapret/zapret-hosts-auto-debug.log 0600 zapret zapret -"
      "z /var/lib/zapret/zapret-hosts-auto-debug.log 0600 zapret zapret -"
    ];
  };
}
