{
  description = "Arch Niri Distro - Nix + Home Manager + Niri Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    niri-config = {
      url = "path:./.config/dotfiles/niri";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.default = pkgs.callPackage ./package.nix {};

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            bash
            gnumake
            coreutils
            util-linux
            parted
            btrfs-progs
            dosfstools
            arch-install-scripts
            git
            curl
            wget
          ];
        };

        apps = rec {
          install = {
            type = "app";
            program = toString (self.packages.${system}.default + /install/install.sh);
          };
          default = install;
        };
      }
    ) // {
      nixosModules = {
        niri = import ./modules/niri;
        home = home-manager.nixosModules.home-manager;
        arch-niri = { config, ... }: {
          imports = [
            ./modules/niri
            home-manager.nixosModules.home-manager
          ];
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.coder = import ./config/home.nix;
        };
      };

      homeConfigurations = {
        coder = home-manager.lib.homeManagerConfiguration {
          inherit(pkgs);
          modules = [ ./config/home.nix ];
        };
      };
    };
}