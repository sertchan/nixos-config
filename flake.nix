{
  description = "seyhan";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
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
