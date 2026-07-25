_: {
  programs.wofi.settings = {
    prompt = "Apps";
    term = "alacritty";
    columns = 2;
    hide_scroll = true;
    no_actions = true;
    sort_order = "default";
    filter_rate = 25; # Filter search results every 25ms to balance responsiveness and CPU load

    width = "25%";
    height = "40%";
    orientation = "vertical";
    line_wrap = "word";

    allow_markup = false;
    allow_images = true;
    image_size = 20;

    parse_search = true;
    insensitive = true;

    key_expand = "Tab";
    key_exit = "Escape";
  };
}
