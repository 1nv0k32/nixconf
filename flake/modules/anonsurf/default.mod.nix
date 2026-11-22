{ self, ... }:
{
  # module.nix, test.nix and the package.nix files are kept identical to the
  # nixpkgs copies; this file only fills in what nixpkgs would provide.
  flake.nixosModules.anonsurf =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ ./module.nix ];

      services.anonsurf = {
        package = lib.mkDefault (pkgs.callPackage ../../packages/anonsurf/package.nix { });
        gui.package = lib.mkDefault (
          pkgs.callPackage ../../packages/anonsurf-gui/package.nix {
            anonsurf = config.services.anonsurf.package;
          }
        );
      };
    };

  perSystem =
    { pkgs, ... }:
    {
      checks.anonsurf = pkgs.testers.runNixOSTest {
        imports = [ ./test.nix ];
        defaults.imports = [ self.nixosModules.anonsurf ];
      };
    };
}
