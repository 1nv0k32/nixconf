{ lib, ... }:
{
  # The niri module turns these on by default; passwords live in pass-secret-service instead.
  services.gnome.gnome-keyring.enable = false;
  xdg.portal.config.niri."org.freedesktop.impl.portal.Secret" = lib.mkForce "none";
}
