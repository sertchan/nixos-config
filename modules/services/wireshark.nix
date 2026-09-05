{ pkgs, ... }: {
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  users.users.seyhan.extraGroups = [ "wireshark" ];
}
