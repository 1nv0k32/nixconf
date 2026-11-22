{
  perSystem =
    { pkgs, ... }:
    {
      packages.anonsurf = pkgs.callPackage ./package.nix { };
    };
}
