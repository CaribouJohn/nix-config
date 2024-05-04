{
  description = "Home Manager configuration of john";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, rust-overlay, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations."john" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        inherit system;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
      
      nixosConfigurations = {
        beast-nix = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix # Your system configuration.
            ({ pkgs, ... }: {
              nixpkgs.overlays = [ rust-overlay.overlays.default ];
              environment.systemPackages = [ 
                pkgs.rust-bin.stable.latest.default
              ];
            })
          ];
        };
      };

    };

}
