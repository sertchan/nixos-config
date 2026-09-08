_: let
  username = "seyhan";
in {
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";
  };
}
