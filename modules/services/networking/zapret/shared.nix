{
  config,
  lib,
}: let
  inherit (builtins) baseNameOf filter isPath map;
  inherit (lib.attrsets) attrValues;
  inherit (lib.modules) mkForce;
  inherit (lib.strings) concatStringsSep hasPrefix;

  zapret2 = config.services.zapret2;

  user = config.users.users.zapret.name;
  group = config.users.groups.zapret.name;

  stateDirectory = "zapret";
  stateDir = "/var/lib/${stateDirectory}";
  networksDir = "${stateDir}/networks";
  currentDir = "${stateDir}/current";
  activityDir = "${stateDir}/by-activity";
  offlineNetwork = "_offline";
  nameFile = "name";
  addedIndex = "added.tsv";

  desyncCapabilities = "CAP_NET_ADMIN CAP_NET_RAW";

  luaFile = file:
    if isPath file || hasPrefix "/" file
    then file
    else "${zapret2.package}/share/zapret2/lua/${file}.lua";

  hostlistNames =
    map (profile: baseNameOf profile.hosts.autodetect.file)
    (filter (profile: profile.hosts.autodetect.enable) (attrValues zapret2.profiles));
in {
  inherit
    stateDirectory
    stateDir
    networksDir
    currentDir
    activityDir
    offlineNetwork
    nameFile
    addedIndex
    user
    group
    ;

  debugLog = "${currentDir}/debug.log";

  retentionDays = 30;
  idleDays = 90;
  cleanupSchedule = "*-*-* 08,20:00:00";

  splitQueue = zapret2.firewall.queue + 1;
  splitCompletedMark = "0x20000000";

  strategy = ./lua/strategy.lua;
  strategyTest = ./lua/strategy-test.lua;
  luaInit = map (file: "--lua-init=@${luaFile file}") zapret2.files;

  nfqwsHardening = {
    AmbientCapabilities = desyncCapabilities;
    CapabilityBoundingSet = desyncCapabilities;
    KeyringMode = "private";
    NoNewPrivileges = true;
    ProtectSystem = mkForce "strict";
    SystemCallArchitectures = "native";
    SystemCallFilter = "@system-service";
  };

  helperHardening = {
    User = user;
    Group = group;
    StateDirectory = [
      stateDirectory
      "${stateDirectory}/networks"
      "${stateDirectory}/by-activity"
    ];
    StateDirectoryMode = "0700";
    CapabilityBoundingSet = "";
    LockPersonality = true;
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateTmp = true;
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectProc = "invisible";
    ProtectSystem = "strict";
    RestrictAddressFamilies = "AF_UNIX AF_NETLINK";
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = "@system-service";
    UMask = "0077";
  };

  requireOwner = ''
    if [ "$(id -un)" != "${user}" ]; then
      echo "zapret state belongs to ${user}, start this through its systemd unit" >&2
      exit 1
    fi
  '';

  shellPaths = ''
    networks_dir=${networksDir}
    current=${currentDir}
    index=${addedIndex}
    name_file=${nameFile}
    hostlists="${concatStringsSep " " hostlistNames}"
  '';
}
