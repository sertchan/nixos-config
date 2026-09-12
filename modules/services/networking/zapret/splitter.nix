{
  config,
  lib,
  utils,
  ...
}: let
  inherit (builtins) bitAnd;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkAfter mkIf;
  inherit (lib.strings) optionalString;
  inherit (lib.trivial) fromHexString;

  cfg = config.services.zapret2;
  settings = import ./settings.nix {inherit config lib;};
  splitPacketFilter = direction:
    if cfg.firewall.maxPackets == null
    then "ct direction ${direction}"
    else "ct ${direction} packets 1-${toString cfg.firewall.maxPackets}";
in
  mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.firewall.configureAutomatically && settings.splitQueue <= 65535;
        message = "zapret TCP splitting requires automatic firewall configuration and services.zapret2.firewall.queue below 65535.";
      }
      {
        assertion = bitAnd (fromHexString cfg.firewall.desyncFwmark) (fromHexString settings.splitCompletedMark) == 0;
        message = "services.zapret2.firewall.desyncFwmark must not use the TCP splitting mark ${settings.splitCompletedMark}.";
      }
    ];

    networking.nftables.tables.zapret2.content = mkAfter ''
      chain split_post {
        type filter hook postrouting priority 102; policy accept;
        ${optionalString (cfg.firewall.interfaces != null) "oifname != $WAN return"}
        ip daddr @local4 return
        ip6 daddr @local6 return
        meta mark & ${settings.splitCompletedMark} != 0 return
        meta l4proto tcp tcp dport { 80, 443 } meta mark & $DESYNC_MARK != 0 queue num ${toString settings.splitQueue} bypass
        meta l4proto tcp tcp dport { 80, 443 } ${splitPacketFilter "original"} meta mark set meta mark | $DESYNC_MARK queue num ${toString settings.splitQueue} bypass
      }
      chain split_pre {
        type filter hook prerouting priority -100; policy accept;
        ${optionalString (cfg.firewall.interfaces != null) "iifname != $WAN return"}
        ip saddr @local4 return
        ip6 saddr @local6 return
        meta mark & $DESYNC_MARK == 0 meta l4proto tcp tcp sport { 80, 443 } ${splitPacketFilter "reply"} queue num ${toString settings.splitQueue} bypass
      }
    '';

    systemd.services."nfqws2@split" = {
      overrideStrategy = "asDropin";
      wantedBy = ["multi-user.target"];
      serviceConfig =
        settings.hardening
        // {
          ExecStart = [
            ""
            (utils.escapeSystemdExecArgs [
              (getExe cfg.package)
              "--qnum=${toString settings.splitQueue}"
              "--fwmark=${settings.splitCompletedMark}"
              "--lua-init=@${cfg.package}/share/zapret2/lua/zapret-lib.lua"
              "--lua-init=@${cfg.package}/share/zapret2/lua/zapret-antidpi.lua"
              "--lua-init=@${settings.strategy}"
              "--filter-tcp=80,443"
              "--payload=http_req,tls_client_hello"
              "--lua-desync=connection_multisplit"
            ])
          ];
          DynamicUser = true;
        };
    };
  }
