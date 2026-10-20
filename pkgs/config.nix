{ self, ... }:
{
  environment.variables = {
    NIXPKGS_ALLOW_UNFREE = "1";
  };

  nix.nixPath = [ "nixpkgs=${self.inputs.nixpkgs}" ];
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnsupportedSystem = true;
    };
    overlays = [ self.overlays.default ];
  };
}
