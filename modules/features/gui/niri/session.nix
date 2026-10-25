# Session settings that do not depend on which shell is active.
{ config, lib, ... }:
{
  services.gnome.gnome-keyring.enable = false;
  # The bar's battery widget reads from UPower.
  services.upower.enable = true;
  # Power profile controls use the power-profiles-daemon D-Bus API, which TLP provides via tlp-pd.
  services.tlp.pd.enable = lib.mkDefault config.services.tlp.enable;

  services.displayManager.defaultSession = "niri";

  # Password storage uses pass-secret-service, not GNOME Keyring's portal.
  xdg.portal.config.niri."org.freedesktop.impl.portal.Secret" = lib.mkForce "none";
}
