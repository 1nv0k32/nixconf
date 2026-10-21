{ inputs, ... }:
{
  flake.nixosModules.media =
    { ... }:
    {
      imports = [
        inputs.nixarr.nixosModules.default
        ./_modules/nginx.nix
        ./_modules/nixarr.nix
        ./_modules/minidlna.nix
      ];
    };
}
