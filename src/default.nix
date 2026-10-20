{
  self,
  ...
}:
{
  imports = [
    (import ./lib/options.nix)
  ];

  system = {
    stateVersion = self.lib.stateVersion;
  };
}
