{
  perSystem =
    { pkgs, self', ... }:
    {
      packages.anonsurf-gui = pkgs.callPackage ./package.nix { inherit (self'.packages) anonsurf; };
    };
}
