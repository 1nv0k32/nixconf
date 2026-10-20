{ inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    {
      packages.nvim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
        inherit pkgs;
        module = ../../pkgs/src/nixvim.nix;
      };
    };
}
