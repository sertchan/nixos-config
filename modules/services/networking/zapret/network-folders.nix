{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;

  cfg = config.modules.services.zapret;
  shared = import ./shared.nix {inherit config lib;};

  selectFolder = pkgs.writeShellApplication {
    name = "zapret-network-select";
    runtimeInputs = with pkgs; [coreutils gawk iproute2 networkmanager];
    text = ''
      ${shared.shellPaths}
      offline=${shared.offlineNetwork}

      device=""
      for probe in 192.0.2.1 2001:db8::1; do
        device=$(ip route get "$probe" 2>/dev/null |
          awk '{for (i = 1; i < NF; i++) if ($i == "dev") {print $(i + 1); exit}}' || true)
        [ -n "''${device:-}" ] && break
      done

      netid=$offline
      label=$offline

      if [ -n "''${device:-}" ]; then
        uuid=$(nmcli -t -f UUID,DEVICE connection show --active |
          awk -F: -v d="$device" '$2 == d {print $1; exit}' || true)
        if [ -n "''${uuid:-}" ]; then
          netid=$uuid
          title=$(nmcli -t -f connection.id connection show "$uuid" | cut -d: -f2- || true)
          label=$(printf '%s' "''${title:-$uuid}" | tr -c 'A-Za-z0-9._-' '_' | cut -c1-48)
        fi
      fi

      folder=$networks_dir/$netid
      mkdir -p "$folder"
      for entry in $hostlists debug.log "$index"; do
        [ -e "$folder/$entry" ] || : > "$folder/$entry"
      done
      printf '%s\n' "$label" > "$folder/$name_file"
      chmod 0700 "$folder"
      chmod 0600 "$folder"/*

      ln -sfn "networks/$netid" "$current.staged"
      mv -Tf "$current.staged" "$current"
      printf 'zapret network %s (%s)\n' "$label" "$netid"
    '';
  };

  followNetworkChange = pkgs.writeShellApplication {
    name = "zapret-network-dispatcher";
    runtimeInputs = with pkgs; [coreutils systemd];
    text = ''
      case "''${2:-}" in
        up | down | vpn-up | vpn-down | connectivity-change) ;;
        *) exit 0 ;;
      esac

      before=$(readlink -f ${shared.currentDir} || true)
      systemctl start zapret-network.service
      after=$(readlink -f ${shared.currentDir} || true)

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
        source = getExe followNetworkChange;
      }
    ];

    systemd.services = {
      zapret-network = {
        description = "Point zapret at the hostlist folder for the current network";
        after = ["NetworkManager.service"];
        serviceConfig =
          shared.helperHardening
          // {
            Type = "oneshot";
            ExecStart = getExe selectFolder;
          };
      };

      "nfqws2@default" = {
        wants = ["zapret-network.service"];
        after = ["zapret-network.service"];
      };
    };
  }
