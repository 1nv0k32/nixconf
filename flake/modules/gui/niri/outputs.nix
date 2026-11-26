let
  internal = "eDP-1";
  profile = name: outputs: { profile = { inherit name outputs; }; };
  laptopScreen = status: {
    criteria = internal;
    inherit status;
  };
  externalScreen = status: {
    criteria = "*";
    inherit status;
  };
in
{
  # niri has no "mirror" or "external only" mode, so kanshi switches outputs through
  # wlr-output-management whenever a display is plugged or unplugged.
  home-manager.sharedModules = [
    {
      services.kanshi = {
        enable = true;
        # niri.service imports WAYLAND_DISPLAY before it reports ready.
        systemdTarget = "niri.service";
        # On hotplug kanshi applies the first matching profile; `extend` and `laptop`
        # are only reached through `kanshictl switch` (Mod+P in binds.nix).
        settings = [
          (profile "internal" [ (laptopScreen "enable") ])
          (profile "external" [
            (laptopScreen "disable")
            (externalScreen "enable")
          ])
          (profile "extend" [
            (laptopScreen "enable")
            (externalScreen "enable")
          ])
          (profile "laptop" [
            (laptopScreen "enable")
            (externalScreen "disable")
          ])
        ];
      };
    }
  ];
}
