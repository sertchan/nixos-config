{
  description = "seyhan";

  inputs = {
    # Track rolling NixOS unstable channel
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      # Align home-manager's nixpkgs dependency with primary system input
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

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
        # Pass inputs into module arguments for global access across NixOS modules
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
