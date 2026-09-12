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
    index=${settings.addedIndex}
    owner=${user}:${group}
    hostlists="${concatStringsSep " " hostlistNames}"
  '';

  populate = ''
    populate() {
      local dir=$1 name
      mkdir -p "$dir"
      for name in $hostlists debug.log "$index"; do
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

  prune = pkgs.writeShellApplication {
    name = "zapret-network-prune";
    runtimeInputs = with pkgs; [coreutils findutils gawk];
    text = ''
      ${environment}
      retention_days=${toString settings.retentionDays}
      log_lines=${toString settings.logLineCap}

      now=$(date +%s)
      cutoff=$((now - retention_days * 86400))
      live=$(readlink -f "$current" || true)

      [ -d "$networks_dir" ] || exit 0
      mkdir -p "$activity_dir"
      chown "$owner" "$activity_dir"
      chmod 0700 "$activity_dir"
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

        chown "$owner" "$dir" "$dir"/*
        chmod 0600 "$dir"/*

        if [ "$activity" -lt "$cutoff" ] && [ "$(readlink -f "$dir")" != "$live" ]; then
          rm -rf "$dir"
          continue
        fi

        stamp=$(date -d "@$activity" +%Y%m%d-%H%M)
        ln -sfn "../networks/$netid" "$activity_dir/$stamp--$netid"
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
          serviceConfig = {
            Type = "oneshot";
            ExecStart = getExe select;
          };
        };

        zapret-network-prune = {
          description = "Expire aged zapret hostlist entries and idle networks";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = getExe prune;
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
