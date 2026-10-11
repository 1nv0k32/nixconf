{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gnome-network-displays
    gnome-terminal
    dconf-editor
    gnome-tweaks
    file-roller
    gnome-calculator
    evolution
    gnome-calendar
  ];

  qt.platformTheme = "gnome";

  services = {
    gnome = {
      core-apps.enable = true;
    };
    desktopManager = {
      gnome.enable = true;
    };
  };
}
