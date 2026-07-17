{
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.zapret ];

  users = {
    # System user for running zapret/nfqws with least privilege
    users.zapret = {
      isSystemUser = true;
      group = "zapret";
      description = "zapret nfqws privilege-drop user";
      shell = "${pkgs.shadow}/bin/nologin"; # no interactive login
    };
    groups.zapret = { }; # Dedicated group for isolation
  };

  networking.nftables = {
    enable = true;
    # Nftables rules for bol-van/zapret
    tables.zapret = {
      family = "inet";
      # Reduces CPU and memory consumption by targeting only connection establishment:
      # TCP 80/443 : Processes 3 ingress & 9 egress packets max
      # UDP 443   : Processes 9 egress packets max (QUIC protocol)
      content = ''
        chain inbound {
          type filter hook input priority -10; policy accept;
          iifname "wlp0s20f3" tcp sport { 80, 443 } ct reply packets 1-3 queue num 200 bypass
        }

        chain outbound {
          type filter hook output priority -10; policy accept;
          oifname "wlp0s20f3" tcp dport { 80, 443 } ct original packets 1-9 queue num 200 bypass
          oifname "wlp0s20f3" udp dport 443 ct original packets 1-9 queue num 200 bypass
        }
      '';
    };
  };

  services.zapret = {
    enable = true;
    # Fake packet DPI desync to bypass censorship/blocking. I also use Autohostlist to prevent websites from breaking
    params = [
      "--dpi-desync=fake"
      "--dpi-desync-ttl=3"
      "--hostlist-auto=/var/lib/zapret/zapret-hosts-auto.txt"
      "--hostlist-auto-fail-threshold=2"
      "--hostlist-auto-debug=/var/lib/zapret/zapret-hosts-auto-debug.log"
    ];
    configureFirewall = false; # Handled manually via nftables above
  };

  systemd = {
    # Hardened sandbox for the zapret service, running as the dedicated non-root user
    services.zapret = {
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = lib.mkForce "zapret";
        Group = lib.mkForce "zapret";
        ReadWritePaths = [ "/var/lib/zapret" ];
        ExecStartPre = [
          "+${pkgs.coreutils}/bin/touch /run/nfqws.pid"
          "+${pkgs.coreutils}/bin/chown zapret:zapret /run/nfqws.pid"
        ];
        # Needed for raw packet manipulation (DPI desync)
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
        SystemCallFilter = [ "@system-service" ];
        SystemCallErrorNumber = "EPERM";
      };
      after = [ "systemd-tmpfiles-setup.service" ];
      wants = [ "systemd-tmpfiles-setup.service" ];
    };
    # Ownership/permissions for zapret's runtime state, since it drops to a non-root user
    tmpfiles.rules = [
      "d /var/lib/zapret 0700 zapret zapret -"
      "f /var/lib/zapret/zapret-hosts-auto.txt 0600 zapret zapret -"
      "z /var/lib/zapret/zapret-hosts-auto.txt 0600 zapret zapret -"
      "f /var/lib/zapret/zapret-hosts-auto-debug.log 0600 zapret zapret -"
      "z /var/lib/zapret/zapret-hosts-auto-debug.log 0600 zapret zapret -"
      "f /run/nfqws.pid 0600 zapret zapret -"
      "z /run/nfqws.pid 0600 zapret zapret -"
    ];
  };
}
