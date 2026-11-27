{ inputs, ... }:
{
  flake.nixosModules.nixvim = {
    imports = [
      inputs.nixvim.nixosModules.nixvim
    ];

    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      # silences nixvim's warning about its nixpkgs input being followed
      nixpkgs.source = inputs.nixpkgs;
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
