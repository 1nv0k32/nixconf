{ lib, ... }:
{
  services.gnome.gnome-keyring.enable = false;
  services.displayManager.defaultSession = "niri";

  # Password storage uses pass-secret-service, not GNOME Keyring's portal.
  xdg.portal.config.niri."org.freedesktop.impl.portal.Secret" = lib.mkForce "none";
}
