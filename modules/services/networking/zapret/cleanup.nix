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

  removeAged = pkgs.writeShellApplication {
    name = "zapret-network-cleanup";
    runtimeInputs = with pkgs; [coreutils findutils gawk];
    text = ''
      ${shared.requireOwner}
      ${shared.shellPaths}
      activity_dir=${shared.activityDir}
      retention_days=${toString shared.retentionDays}
      idle_days=${toString shared.idleDays}
      log_lines=${toString shared.logLineCap}

      now=$(date +%s)
      domain_cutoff=$((now - retention_days * 86400))
      folder_cutoff=$((now - idle_days * 86400))
      live=$(readlink -f "$current" || true)

      [ -d "$networks_dir" ] || exit 0
      find "$activity_dir" -maxdepth 1 -type l -delete

      for folder in "$networks_dir"/*; do
        [ -d "$folder" ] || continue
        netid=$(basename "$folder")
        created=$(stat -c %Y "$folder")
        recorded=0
        [ -s "$folder/activity" ] && recorded=$(cat "$folder/activity")

        [ -e "$folder/$index" ] || : > "$folder/$index"
        [ -e "$folder/debug.log" ] || : > "$folder/debug.log"
        previous=$(cut -f1 "$folder/$index" | sort -n | tail -1)
        staged=$folder/$index.staged
        : > "$staged"

        for list in $hostlists; do
          [ -f "$folder/$list" ] || continue
          gawk -v now="$now" -v cutoff="$domain_cutoff" -v list="$list" \
            -v indexfile="$folder/$index" -v logfile="$folder/debug.log" -v staged="$staged" '
            BEGIN {
              FS = "\t"
              while ((getline row < indexfile) > 0) {
                split(row, field, "\t")
                if (field[2] == list) first_seen[field[3]] = field[1]
              }
              close(indexfile)
              added = "^([0-9]{2})\\.([0-9]{2})\\.([0-9]{4}) ([0-9]{2}):([0-9]{2}):([0-9]{2}) : ([^ ]+) : .* : adding to (.+)$"
              while ((getline line < logfile) > 0) {
                if (!match(line, added, at)) continue
                target = at[8]
                sub(/^.*\//, "", target)
                if (target != list) continue
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
              printf "%s\t%s\t%s\n", stamp, list, domain >> staged
            }
          ' "$folder/$list" > "$folder/$list.staged"
          mv -Tf "$folder/$list.staged" "$folder/$list"
        done

        mv -Tf "$staged" "$folder/$index"

        if [ -f "$folder/debug.log" ]; then
          gawk -v cutoff="$domain_cutoff" '
            match($0, /^([0-9]{2})\.([0-9]{2})\.([0-9]{4}) ([0-9]{2}):([0-9]{2}):([0-9]{2})/, at) {
              stamp = mktime(at[3] " " at[2] " " at[1] " " at[4] " " at[5] " " at[6])
              if (stamp >= 0 && stamp < cutoff) { drop = 1; next }
              drop = 0
              print
              next
            }
            !drop
          ' "$folder/debug.log" | tail -n "$log_lines" > "$folder/debug.log.staged"
          mv -Tf "$folder/debug.log.staged" "$folder/debug.log"
        fi

        activity=$recorded
        for stamp in "''${previous:-0}" "$(cut -f1 "$folder/$index" | sort -n | tail -1)"; do
          [ -n "$stamp" ] && [ "$stamp" -gt "$activity" ] && activity=$stamp
        done
        [ "$activity" -gt 0 ] || activity=$created
        printf '%s\n' "$activity" > "$folder/activity"

        chmod 0600 "$folder"/*

        if [ "$activity" -lt "$folder_cutoff" ] && [ "$(readlink -f "$folder")" != "$live" ]; then
          rm -rf "$folder"
          continue
        fi

        label=$netid
        [ -s "$folder/$name_file" ] && label=$(cat "$folder/$name_file")
        stamp=$(date -d "@$activity" +%Y%m%d-%H%M)
        ln -sfn "../networks/$netid" "$activity_dir/$stamp--$label--''${netid%%-*}"
      done
    '';
  };
in
  mkIf cfg.enable {
    systemd = {
      services.zapret-network-cleanup = {
        description = "Remove aged zapret hostlist entries and unused networks";
        serviceConfig =
          shared.helperHardening
          // {
            Type = "oneshot";
            ExecStart = getExe removeAged;
            PrivateDevices = true;
            PrivateNetwork = true;
            ProtectHostname = true;
            ProtectProc = "invisible";
          };
      };

      timers.zapret-network-cleanup = {
        description = "Remove aged zapret hostlist entries and unused networks";
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = shared.cleanupSchedule;
          Persistent = true;
          RandomizedDelaySec = "5m";
        };
      };
    };
  }
