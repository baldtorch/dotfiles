{
  # Update dependencies deliberately with `nix flake update`, then build/test.
  description = "Reproducible AMD Hyprland workstation with wallpaper-driven colors";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vm-curator = {
      url = "github:mroboff/vm-curator";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      vm-curator,
    }:
    let
      system = "x86_64-linux";
      settings = import ./hosts/workstation/settings.nix;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate =
          pkg:
          builtins.elem (nixpkgs.lib.getName pkg) [
            "steam"
            "steam-unwrapped"
            "steam-run"
            "vscode"
            "via"
          ];
      };
      mkHost =
        validation: extraModules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            settings = settings // {
              hardwareReady = validation || settings.hardwareReady;
            };
          };
          modules = [
            ./hosts/workstation
            home-manager.nixosModules.home-manager
            {
              nixpkgs.pkgs = pkgs;
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {
                  inherit settings;
                  vmCurator = vm-curator.packages.${system}.default;
                };
                users.${settings.username} = import ./home;
              };
            }
          ]
          ++ extraModules;
        };
      # CI uses an explicit fake disk layout; never install this host on hardware.
      checkHost = mkHost true [ ./tests/hardware.nix ];
    in
    {
      nixosConfigurations.workstation = mkHost false [ ];
      nixosConfigurations.check = checkHost;
      formatter.${system} = pkgs.nixfmt-tree;
      devShells.${system} = import ./devshells { inherit pkgs; };
      packages.${system} = import ./packages { inherit pkgs; };
      checks.${system} = {
        # Force complete module evaluation without building the whole OS in CI.
        system-evaluation = pkgs.runCommand "system-evaluation" { } ''
          echo ${builtins.unsafeDiscardStringContext checkHost.config.system.build.toplevel.drvPath} > "$out"
        '';
        theme = self.packages.${system}.rice-theme;
        hyprland = import ./tests/hyprland.nix {
          inherit pkgs;
          home = checkHost.config.home-manager.users.${settings.username};
          theme = self.packages.${system}.rice-theme;
        };
      };
    };
}
