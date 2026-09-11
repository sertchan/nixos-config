{config}: let
  cfg = config.services.zapret2;
  stateDirectory = "zapret";
  stateDir = "/var/lib/${stateDirectory}";
in {
  inherit stateDirectory stateDir;
  autoHostlistDir = "${stateDir}/autohostlist-hosts";
  autoHostlistDebugLog = "${stateDir}/autohostlist-debug.log";
  splitQueue = cfg.firewall.queue + 1;
  splitCompletedMark = "0x20000000";
  strategy = ./strategy.lua;
}
