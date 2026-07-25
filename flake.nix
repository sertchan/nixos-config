{
  description = "seyhan";

  # ----- Flake Inputs -----
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      # Ensure home-manager uses the same nixpkgs instance as the system
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # ----- Flake Outputs -----
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    {
      nixosConfigurations.arda-nirvana = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        # Forward flake inputs to all NixOS and Home Manager modules
        specialArgs = { inherit self inputs; };
        modules = [
          { nixpkgs.config.allowUnfree = true; }
          home-manager.nixosModules.home-manager
          ./hosts/arda-nirvana/default.nix
          ./homes
        ];
      };
    };
}
