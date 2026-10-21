{
  flake.nixosModules.media =
    { ... }:
    {
      imports = [
        ./_modules/nginx.nix
        ./_modules/nixarr.nix
        ./_modules/minidlna.nix
      ];
    };
}
