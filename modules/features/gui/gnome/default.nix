{
  flake.nixosModules.gui-gnome =
    { lib, ... }:
    {
      imports = [ ./_modules/desktop.nix ];

      services.displayManager.gdm = {
        enable = lib.mkDefault true;
        autoSuspend = false;
      };
    };
}
