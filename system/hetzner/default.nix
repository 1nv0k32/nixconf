{ self, ... }:
{
  imports = [
    (import ./disko.nix)
    (import "${self}/modules/services/wg.nix")
  ];
}
