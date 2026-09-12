{
  config,
  lib,
}: let
  inherit (builtins) isPath;
  inherit (lib.modules) mkForce;
  inherit (lib.strings) hasPrefix;

  zapret2 = config.services.zapret2;

  stateDirectory = "zapret";
  stateDir = "/var/lib/${stateDirectory}";
  networksDir = "${stateDir}/networks";
  currentDir = "${stateDir}/current";
  activityDir = "${stateDir}/by-activity";
  offlineNetwork = "_offline";

  desyncCapabilities = "CAP_NET_ADMIN CAP_NET_RAW";

  luaFile = file:
    if isPath file || hasPrefix "/" file
    then file
    else "${zapret2.package}/share/zapret2/lua/${file}.lua";
in {
  inherit stateDirectory stateDir networksDir currentDir activityDir offlineNetwork;
  debugLog = "${currentDir}/debug.log";
  addedIndex = "added.tsv";
  retentionDays = 30;
  logLineCap = 20000;
  pruneSchedule = "*-*-* 00,06,12,18:00:00";
  splitQueue = zapret2.firewall.queue + 1;
  splitCompletedMark = "0x20000000";
  strategy = ./strategy.lua;
  luaInit = map (file: "--lua-init=@${luaFile file}") zapret2.files;

  hardening = {
    AmbientCapabilities = desyncCapabilities;
    CapabilityBoundingSet = desyncCapabilities;
    KeyringMode = "private";
    NoNewPrivileges = true;
    ProtectSystem = mkForce "strict";
    SystemCallArchitectures = "native";
    SystemCallFilter = "@system-service";
  };
}
