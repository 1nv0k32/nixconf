{
  inputs = {
    cfg = {
      url = "git+https://codeberg.org/1nv0k32/nixconf";
    };
  };

  outputs =
    { cfg, ... }:
    let
      withLocal = builtins.mapAttrs (
        _: sys:
        sys.extendModules {
          modules = builtins.filter builtins.pathExists [
            ./hardware-configuration.nix
            ./local.nix
          ];
        }
      );
    in
    {
      nixosConfigurations = withLocal cfg.nixosConfigurations;
      darwinConfigurations = withLocal cfg.darwinConfigurations;
    };
}
