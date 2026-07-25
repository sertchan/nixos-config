_: {
  programs.starship = {
    enable = true;

    settings = {
      # ----- Prompt Layout & Structure -----
      format = "$username$hostname$directory$git_branch$git_state$git_status$git_metrics$fill$nodejs$cmd_duration $jobs $time$line_break$character";

      fill.symbol = " ";

      directory = {
        style = "blue";
        read_only = " [RO]";
        truncation_length = 4;
        truncate_to_repo = false;
      };

      character = {
        success_symbol = "[❯](green)";
        error_symbol = "[❯](red)";
        vicmd_symbol = "[❮](green)";
      };

      # ----- Git Version Control -----
      git_branch = {
        symbol = " ";
        format = "[$symbol$branch]($style) ";
        style = "bright-black";
      };

      git_status = {
        # Nix indented string ('' ... '') preserves literal backslashes without escaping
        format = ''([\[$all_status$ahead_behind\]]($style) )'';
        style = "cyan";
      };

      git_state = {
        format = ''\([$state( $progress_current/$progress_total)]($style)\) '';
        style = "bright-black";
      };

      git_metrics.disabled = false;

      # ----- System & Runtime Indicators -----
      nodejs.format = "[$symbol($version )]($style)";

      jobs = {
        symbol = "[J]";
        style = "bold red";
        number_threshold = 1;
        format = "[$symbol]($style)";
      };

      cmd_duration = {
        format = "[$duration]($style)";
        style = "yellow";
      };

      memory_usage.symbol = "M: ";

      time = {
        disabled = false;
        style = "bold gray";
        format = "[$time]($style)";
      };
    };
  };
}
