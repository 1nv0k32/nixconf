{ self, ... }:
{
  perSystem =
    { lib, pkgs, ... }:
    {
      checks = lib.optionalAttrs pkgs.stdenv.isLinux {
        niri-scripts = pkgs.runCommand "niri-scripts-tests" { nativeBuildInputs = [ pkgs.python3 ]; } ''
          cd ${
            lib.fileset.toSource {
              root = ./.;
              fileset = lib.fileset.unions [
                ./assets
                ./tests
              ];
            }
          }
          PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests
          touch $out
        '';
      };
    };

  flake.nixosModules.gui-niri =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        ./compositor.nix
        ./session.nix
      ];

      _module.args.niriShell = import ./shell.nix {
        inherit self lib pkgs;
        fingerprint = config.services.fprintd.enable;
      };
    };
}
