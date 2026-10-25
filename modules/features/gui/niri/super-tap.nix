# niri binds fire on key press only, so keyd turns a lone Super tap into F24, which binds.nix maps
# to the overview. Holding Super past the timeout (e.g. Super+drag) does not count as a tap.
{
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        global.overload_tap_timeout = 200;
        main.leftmeta = "overload(meta, f24)";
      };
    };
  };
}
