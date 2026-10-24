{ inputs, ... }:
{
  flake.nixosModules.media =
    { ... }:
    {
      imports = [
        inputs.nixarr.nixosModules.default
        ./nginx.nix
        ./nixarr.nix
        ./minidlna.nix
      ];
    };
}
