{ inputs, ... }:
let
  nixvimModule = {
    programs.nixvim = {
      enable = true;
      imports = [
        ./_config.nix
      ];
    };
  };
in
{
  flake = {
    nixosModules.nixvim = {
      imports = [ nixvimModule ];
      programs.nixvim.defaultEditor = true;
    };
    darwinModules.nixvim =
      { config, lib, ... }:
      {
        imports = [ nixvimModule ];
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
        module = ./_config.nix;
      };
    };
}
