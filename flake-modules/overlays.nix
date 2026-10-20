{ inputs, ... }:
{
  flake.overlays.default =
    _: prev:
    builtins.mapAttrs
      (
        _: nixpkgs:
        import nixpkgs {
          system = prev.stdenv.hostPlatform.system;
          config = {
            allowUnfree = true;
            allowUnsupportedSystem = true;
          };
        }
      )
      {
        master = inputs.nixpkgs-master;
        unstable = inputs.nixpkgs-unstable;
        old = inputs.nixpkgs-old;
      };
}
