{ self, ... }:
{
  perSystem =
    { lib, pkgs, ... }:
    {
      checks = lib.optionalAttrs pkgs.stdenv.isLinux {
        niri-scripts = pkgs.runCommand "niri-scripts-tests" { nativeBuildInputs = [ pkgs.python3 ]; } ''
          cd ${
            lib.fileset.toSource {
              root = ./custom-shell;
              fileset = lib.fileset.unions [
                ./custom-shell/assets
                ./custom-shell/tests
              ];
            }
          }
          PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests
          touch $out
        '';
      };
    };

  flake.nixosModules.gui-niri = {
    imports = [
      ./compositor.nix
      ./session.nix
      # Swap for (import ./custom-shell { inherit self; }) to go back to the Waybar-based shell and ly.
      (import ./noctalia { inherit self; })
    ];
  };
}
