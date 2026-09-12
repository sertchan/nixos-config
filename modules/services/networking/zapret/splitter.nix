{
  config,
  lib,
  utils,
  ...
}: let
  inherit (builtins) bitAnd;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkAfter mkIf;
  inherit (lib.strings) concatMapStringsSep optionalString;
  inherit (lib.trivial) fromHexString;

  cfg = config.modules.services.zapret;
  zapret2 = config.services.zapret2;
  shared = import ./shared.nix {inherit config lib;};

  splitPacketFilter = direction:
    if zapret2.firewall.maxPackets == null
    then "ct direction ${direction}"
    else "ct ${direction} packets $PKT";
in
  mkIf cfg.enable {
    assertions = [
      {
        assertion = zapret2.firewall.configureAutomatically && shared.splitQueue <= 65535;
        message = "zapret TCP splitting requires automatic firewall configuration and services.zapret2.firewall.queue below 65535.";
      }
      {
        assertion = zapret2.firewall.tcpPorts != null && zapret2.firewall.tcpPorts != [];
        message = "zapret TCP splitting follows services.zapret2.firewall.tcpPorts, so the list must name at least one port.";
      }
      {
        assertion = bitAnd (fromHexString zapret2.firewall.desyncFwmark) (fromHexString shared.splitCompletedMark) == 0;
        message = "services.zapret2.firewall.desyncFwmark must not use the TCP splitting mark ${shared.splitCompletedMark}.";
      }
    ];

    networking.nftables.tables.zapret2.content = mkAfter ''
      chain split_post {
        type filter hook postrouting priority 102; policy accept;
        ${optionalString (zapret2.firewall.interfaces != null) "oifname != $WAN return"}
        ip daddr @local4 return
        ip6 daddr @local6 return
        meta mark & ${shared.splitCompletedMark} != 0 return
        meta l4proto tcp tcp dport $TCP_PORT meta mark & $DESYNC_MARK != 0 queue num ${toString shared.splitQueue} bypass
        meta l4proto tcp tcp dport $TCP_PORT ${splitPacketFilter "original"} meta mark set meta mark | $DESYNC_MARK queue num ${toString shared.splitQueue} bypass
      }
      chain split_pre {
        type filter hook prerouting priority -100; policy accept;
        ${optionalString (zapret2.firewall.interfaces != null) "iifname != $WAN return"}
        ip saddr @local4 return
        ip6 saddr @local6 return
        meta mark & $DESYNC_MARK == 0 meta l4proto tcp tcp sport $TCP_PORT ${splitPacketFilter "reply"} queue num ${toString shared.splitQueue} bypass
      }
    '';

    systemd.services."nfqws2@split" = {
      overrideStrategy = "asDropin";
      wantedBy = ["multi-user.target"];
      serviceConfig =
        shared.nfqwsHardening
        // {
          ExecStart = [
            ""
            (utils.escapeSystemdExecArgs (
              [
                (getExe zapret2.package)
                "--qnum=${toString shared.splitQueue}"
                "--fwmark=${shared.splitCompletedMark}"
              ]
              ++ shared.luaInit
              ++ [
                "--filter-tcp=${concatMapStringsSep "," toString zapret2.firewall.tcpPorts}"
                "--payload=http_req,tls_client_hello"
                "--lua-desync=connection_multisplit"
              ]
            ))
          ];
          DynamicUser = true;
        };
    };
  }
