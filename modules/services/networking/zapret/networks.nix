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

  hardening = {
    User = user;
    Group = group;
    StateDirectory = [
      settings.stateDirectory
      "${settings.stateDirectory}/networks"
      "${settings.stateDirectory}/by-activity"
    ];
    StateDirectoryMode = "0700";
    CapabilityBoundingSet = "";
    LockPersonality = true;
    NoNewPrivileges = true;
    PrivateTmp = true;
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectSystem = "strict";
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = "@system-service";
  };

  hostlistNames =
    map (profile: baseNameOf profile.hosts.autodetect.file)
    (filter (profile: profile.hosts.autodetect.enable) (attrValues zapret2.profiles));

  environment = ''
    networks_dir=${settings.networksDir}
    current=${settings.currentDir}
    index=${settings.addedIndex}
    hostlists="${concatStringsSep " " hostlistNames}"
  '';

  populate = ''
    populate() {
      local dir=$1 name
      mkdir -p "$dir"
      for name in $hostlists debug.log "$index"; do
        [ -e "$dir/$name" ] || : > "$dir/$name"
      done
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

      populate "$networks_dir/$netid"
      printf '%s\n' "$label" > "$networks_dir/$netid/name"
      chmod 0600 "$networks_dir/$netid/name"
      ln -sfn "networks/$netid" "$current.staged"
      mv -Tf "$current.staged" "$current"
      printf 'zapret network %s (%s)\n' "$label" "$netid"
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

  prune = pkgs.writeShellApplication {
    name = "zapret-network-prune";
    runtimeInputs = with pkgs; [coreutils findutils gawk];
    text = ''
      ${environment}
      activity_dir=${settings.activityDir}
      retention_days=${toString settings.retentionDays}
      idle_days=${toString settings.idleDays}
      log_lines=${toString settings.logLineCap}

      now=$(date +%s)
      cutoff=$((now - retention_days * 86400))
      idle_cutoff=$((now - idle_days * 86400))
      live=$(readlink -f "$current" || true)

      [ -d "$networks_dir" ] || exit 0
      find "$activity_dir" -maxdepth 1 -type l -delete

      for dir in "$networks_dir"/*; do
        [ -d "$dir" ] || continue
        netid=$(basename "$dir")
        created=$(stat -c %Y "$dir")
        recorded=0
        [ -s "$dir/activity" ] && recorded=$(cat "$dir/activity")

        [ -e "$dir/$index" ] || : > "$dir/$index"
        [ -e "$dir/debug.log" ] || : > "$dir/debug.log"
        previous=$(cut -f1 "$dir/$index" | sort -n | tail -1)
        staged=$dir/$index.staged
        : > "$staged"

        for name in $hostlists; do
          [ -f "$dir/$name" ] || continue
          gawk -v now="$now" -v cutoff="$cutoff" -v name="$name" \
            -v indexfile="$dir/$index" -v logfile="$dir/debug.log" -v staged="$staged" '
            BEGIN {
              FS = "\t"
              while ((getline row < indexfile) > 0) {
                split(row, field, "\t")
                if (field[2] == name) first_seen[field[3]] = field[1]
              }
              close(indexfile)
              added = "^([0-9]{2})\\.([0-9]{2})\\.([0-9]{4}) ([0-9]{2}):([0-9]{2}):([0-9]{2}) : ([^ ]+) : .* : adding to (.+)$"
              while ((getline line < logfile) > 0) {
                if (!match(line, added, at)) continue
                target = at[8]
                sub(/^.*\//, "", target)
                if (target != name) continue
                stamp = mktime(at[3] " " at[2] " " at[1] " " at[4] " " at[5] " " at[6])
                if (stamp > 0 && (!(at[7] in logged) || stamp > logged[at[7]])) logged[at[7]] = stamp
              }
              close(logfile)
            }
            {
              domain = $0
              gsub(/^[ \t\r]+|[ \t\r]+$/, "", domain)
              if (domain == "") next
              if (domain in written) next
              written[domain] = 1
              if (domain in first_seen) stamp = first_seen[domain]
              else if (domain in logged) stamp = logged[domain]
              else stamp = now
              if (stamp < cutoff) next
              print domain
              printf "%s\t%s\t%s\n", stamp, name, domain >> staged
            }
          ' "$dir/$name" > "$dir/$name.staged"
          mv -Tf "$dir/$name.staged" "$dir/$name"
        done

        mv -Tf "$staged" "$dir/$index"

        if [ -f "$dir/debug.log" ]; then
          gawk -v cutoff="$cutoff" '
            match($0, /^([0-9]{2})\.([0-9]{2})\.([0-9]{4}) ([0-9]{2}):([0-9]{2}):([0-9]{2})/, at) {
              stamp = mktime(at[3] " " at[2] " " at[1] " " at[4] " " at[5] " " at[6])
              if (stamp >= 0 && stamp < cutoff) { drop = 1; next }
              drop = 0
              print
              next
            }
            !drop
          ' "$dir/debug.log" | tail -n "$log_lines" > "$dir/debug.log.staged"
          mv -Tf "$dir/debug.log.staged" "$dir/debug.log"
        fi

        activity=$recorded
        for stamp in "''${previous:-0}" "$(cut -f1 "$dir/$index" | sort -n | tail -1)"; do
          [ -n "$stamp" ] && [ "$stamp" -gt "$activity" ] && activity=$stamp
        done
        [ "$activity" -gt 0 ] || activity=$created
        printf '%s\n' "$activity" > "$dir/activity"

        chmod 0600 "$dir"/*

        if [ "$activity" -lt "$idle_cutoff" ] && [ "$(readlink -f "$dir")" != "$live" ]; then
          rm -rf "$dir"
          continue
        fi

        label=$netid
        [ -s "$dir/name" ] && label=$(cat "$dir/name")
        stamp=$(date -d "@$activity" +%Y%m%d-%H%M)
        ln -sfn "../networks/$netid" "$activity_dir/$stamp--$label--''${netid%%-*}"
      done
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
          after = ["NetworkManager.service"];
          serviceConfig =
            hardening
            // {
              Type = "oneshot";
              ExecStart = getExe select;
            };
        };

        zapret-network-prune = {
          description = "Expire aged zapret hostlist entries and idle networks";
          serviceConfig =
            hardening
            // {
              Type = "oneshot";
              ExecStart = getExe prune;
              PrivateDevices = true;
              PrivateNetwork = true;
              ProtectHostname = true;
              ProtectProc = "invisible";
            };
        };

        "nfqws2@default" = {
          wants = ["zapret-network.service"];
          after = ["zapret-network.service"];
        };
      };

      timers.zapret-network-prune = {
        description = "Expire aged zapret hostlist entries and idle networks";
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = settings.pruneSchedule;
          Persistent = true;
          RandomizedDelaySec = "5m";
        };
      };
    };
  }
