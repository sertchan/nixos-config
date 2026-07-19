{ pkgs, ... }: {
  users = {
    defaultUserShell = pkgs.zsh;

    users.seyhan = {
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
    };
  };
}
