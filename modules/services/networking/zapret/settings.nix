{
  config,
  lib,
}: let
  inherit (lib.modules) mkForce;

  cfg = config.services.zapret2;

  stateDirectory = "zapret";
  stateDir = "/var/lib/${stateDirectory}";

  desyncCapabilities = "CAP_NET_ADMIN CAP_NET_RAW";
in {
  inherit stateDirectory stateDir;
  autoHostlistDir = "${stateDir}/autohostlist-hosts";
  autoHostlistDebugLog = "${stateDir}/autohostlist-debug.log";
  splitQueue = cfg.firewall.queue + 1;
  splitCompletedMark = "0x20000000";
  strategy = ./strategy.lua;

  hardening = {
    AmbientCapabilities = desyncCapabilities;
    CapabilityBoundingSet = desyncCapabilities;
    DevicePolicy = "closed";
    KeyringMode = "private";
    NoNewPrivileges = true;
    ProtectSystem = mkForce "strict";
    SystemCallArchitectures = "native";
    SystemCallErrorNumber = "EPERM";
    SystemCallFilter = "@system-service";
  };
}
