{ inputs, ... }:
let
  nixvimModule = {
    programs.nixvim = {
      enable = true;
      imports = [
        ./config.nix
      ];
    };
  };
in
{
  flake = {
    nixosModules.nixvim = {
      imports = [
        inputs.nixvim.nixosModules.nixvim
        nixvimModule
      ];
      programs.nixvim.defaultEditor = true;
    };
    darwinModules.nixvim =
      { config, lib, ... }:
      {
        imports = [
          inputs.nixvim.nixDarwinModules.nixvim
          nixvimModule
        ];
        environment.variables = lib.mkIf config.programs.nixvim.enable {
          EDITOR = lib.mkOverride 900 "nvim";
          VISUAL = lib.mkOverride 900 "nvim";
        };
      };
  };

  perSystem =
    { pkgs, system, ... }:
    {
      packages.nvim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
        inherit pkgs;
        module = ./config.nix;
      };
    };
}
