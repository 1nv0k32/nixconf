{ inputs, ... }:
{
  imports = [ inputs.flake-parts.flakeModules.modules ];

  flake.modules.nixos.media =
    { ... }:
    {
      imports = [
        ./_modules/nginx.nix
        ./_modules/nixarr.nix
        ./_modules/minidlna.nix
      ];
    };
}
