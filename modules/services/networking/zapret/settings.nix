{
  config,
  lib,
}: let
  inherit (builtins) isPath;
  inherit (lib.modules) mkForce;
  inherit (lib.strings) hasPrefix;

  cfg = config.services.zapret2;

  stateDirectory = "zapret";
  stateDir = "/var/lib/${stateDirectory}";

  desyncCapabilities = "CAP_NET_ADMIN CAP_NET_RAW";

  luaFile = file:
    if isPath file || hasPrefix "/" file
    then file
    else "${cfg.package}/share/zapret2/lua/${file}.lua";
in {
  inherit stateDirectory stateDir;
  autoHostlistDir = "${stateDir}/autohostlist-hosts";
  autoHostlistDebugLog = "${stateDir}/autohostlist-debug.log";
  splitQueue = cfg.firewall.queue + 1;
  splitCompletedMark = "0x20000000";
  strategy = ./strategy.lua;
  luaInit = map (file: "--lua-init=@${luaFile file}") cfg.files;

  hardening = {
    AmbientCapabilities = desyncCapabilities;
    CapabilityBoundingSet = desyncCapabilities;
    KeyringMode = "private";
    NoNewPrivileges = true;
    ProtectSystem = mkForce "strict";
    SystemCallArchitectures = "native";
    SystemCallErrorNumber = "EPERM";
    SystemCallFilter = "@system-service";
  };
}
