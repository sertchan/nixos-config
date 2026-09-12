{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) baseNameOf filter map;
  inherit (lib.attrsets) attrValues;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.strings) concatStringsSep;

  cfg = config.modules.services.zapret;
  zapret2 = config.services.zapret2;
  settings = import ./settings.nix {inherit config lib;};

  user = config.users.users.zapret.name;
  group = config.users.groups.zapret.name;

  hostlistNames =
    map (profile: baseNameOf profile.hosts.autodetect.file)
    (filter (profile: profile.hosts.autodetect.enable) (attrValues zapret2.profiles));

  environment = ''
    networks_dir=${settings.networksDir}
    activity_dir=${settings.activityDir}
    current=${settings.currentDir}
    owner=${user}:${group}
    hostlists="${concatStringsSep " " hostlistNames}"
  '';

  populate = ''
    populate() {
      local dir=$1 name
      mkdir -p "$dir"
      for name in $hostlists debug.log; do
        [ -e "$dir/$name" ] || : > "$dir/$name"
      done
      chown "$owner" "$dir" "$dir"/*
      chmod 0700 "$dir"
      chmod 0600 "$dir"/*
    }
  '';

  select = pkgs.writeShellApplication {
    name = "zapret-network-select";
    runtimeInputs = with pkgs; [coreutils gawk iproute2 networkmanager];
    text = ''
      ${environment}
      ${populate}
      offline=${settings.offlineNetwork}

      device=$(ip route show default | awk '/^default/ {print $5; exit}' || true)
      netid=$offline

      if [ -n "''${device:-}" ]; then
        uuid=$(nmcli -t -f UUID,DEVICE connection show --active |
          awk -F: -v d="$device" '$2 == d {print $1; exit}' || true)
        if [ -n "''${uuid:-}" ]; then
          label=$(nmcli -t -f connection.id connection show "$uuid" | cut -d: -f2- || true)
          slug=$(printf '%s' "''${label:-$uuid}" | tr -c 'A-Za-z0-9._-' '_' | cut -c1-48)
          netid="''${slug}-''${uuid%%-*}"
        fi
      fi

      mkdir -p "$networks_dir" "$activity_dir"
      chown "$owner" "$networks_dir" "$activity_dir"
      chmod 0700 "$networks_dir" "$activity_dir"
      populate "$networks_dir/$netid"
      ln -sfn "networks/$netid" "$current.staged"
      mv -Tf "$current.staged" "$current"
      printf 'zapret network %s\n' "$netid"
    '';
  };

  dispatcher = pkgs.writeShellApplication {
    name = "zapret-network-dispatcher";
    runtimeInputs = with pkgs; [coreutils systemd];
    text = ''
      case "''${2:-}" in
        up | down | vpn-up | vpn-down | connectivity-change) ;;
        *) exit 0 ;;
      esac

      before=$(readlink -f ${settings.currentDir} || true)
      systemctl start zapret-network.service
      after=$(readlink -f ${settings.currentDir} || true)

      if [ "''${before:-}" != "''${after:-}" ]; then
        systemctl try-restart nfqws2@default.service
      fi
    '';
  };
in
  mkIf cfg.enable {
    networking.networkmanager.dispatcherScripts = [
      {
        type = "basic";
        source = getExe dispatcher;
      }
    ];

    systemd = {
      services = {
        zapret-network = {
          description = "Select per network zapret hostlist directory";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = getExe select;
          };
        };

        "nfqws2@default" = {
          wants = ["zapret-network.service"];
          after = ["zapret-network.service"];
        };
      };
    };
  }
