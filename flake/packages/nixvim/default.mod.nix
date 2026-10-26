{ inputs, ... }:
{
  flake.nixosModules.nixvim = {
    imports = [
      inputs.nixvim.nixosModules.nixvim
    ];

    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      imports = [
        ./config.nix
      ];
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
