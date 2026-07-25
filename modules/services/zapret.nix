{
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.zapret ]; # Anti-DPI censorship bypass tool

  users = {
    # Dedicated unprivileged system user for zapret daemon privilege-dropping
    users.zapret = {
      isSystemUser = true;
      group = "zapret";
      description = "zapret nfqws privilege-drop user";
      shell = "${pkgs.shadow}/bin/nologin"; # Disable interactive login shell
    };
    groups.zapret = { };
  };

  networking.nftables = {
    enable = true;
    tables.zapret = {
      family = "inet";
      # Targets connection establishment packets to reduce CPU/memory load:
      # TCP 80/443 : Intercepts first 3 ingress and 9 egress packets
      # UDP 443    : Intercepts first 9 egress packets (QUIC traffic)
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
    # Inject fake packets to desynchronize DPI middleboxes while using autohostlist to avoid site breakage
    params = [
      "--dpi-desync=fake"
      "--dpi-desync-ttl=3"
      "--hostlist-auto=/var/lib/zapret/zapret-hosts-auto.txt"
      "--hostlist-auto-fail-threshold=2"
      "--hostlist-auto-debug=/var/lib/zapret/zapret-hosts-auto-debug.log"
    ];
    configureFirewall = false; # Handled via custom nftables rules above
  };

  systemd = {
    # Hardened systemd service wrapper running zapret as dedicated non-root user
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
        # Capabilities required for raw packet redirection and socket manipulation
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

    # State directory ownership and permission rules for non-root zapret user
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
