{inputs}: let
  system = "x86_64-linux";
  pkgs = inputs.nixpkgs.legacyPackages.${system};
in {
  nixosConfigurations = import ../hosts {inherit inputs;};
  checks.${system} = import ./checks.nix {
    inherit pkgs;
    inherit (inputs) self;
  };
  devShells.${system}.default = import ./shell.nix {inherit pkgs;};
  formatter.${system} = import ./fmt.nix {inherit pkgs;};
}
