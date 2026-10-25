{
  config,
  lib,
  pkgs,
  ...
}:
let
  theme = import ../theme.nix { inherit pkgs; };
  noctalia = lib.getExe config.programs.noctalia.package;

  configFile = (pkgs.formats.toml { }).generate "noctalia-config.toml" (
    import ./settings.nix { inherit config theme; }
  );
  # Noctalia reads $NOCTALIA_CONFIG_HOME/noctalia/*.toml. Changes made in its Settings window go to
  # ~/.local/state/noctalia/settings.toml and override this file.
  configHome = pkgs.runCommand "noctalia-config" { } ''
    HOME=$TMPDIR ${noctalia} config validate ${configFile}
    mkdir -p $out/noctalia
    cp ${configFile} $out/noctalia/config.toml
  '';
in
{
  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
    systemd = {
      enable = true;
      # niri.service imports WAYLAND_DISPLAY and NIRI_SOCKET before it reports ready.
      target = "niri.service";
    };
  };
  # A changed config changes the unit, so a rebuild restarts the shell with it.
  systemd.user.services.noctalia.environment.NOCTALIA_CONFIG_HOME = "${configHome}";

  # External monitor brightness: Noctalia runs ddcutil, which needs /dev/i2c-* access.
  hardware.i2c.enable = true;
  environment.systemPackages = [ pkgs.ddcutil ];
}
