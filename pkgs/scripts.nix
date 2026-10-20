{ self, pkgs, ... }:
let
  commands = self.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  environment.systemPackages = [
    commands.nixconf
    commands.nixup
  ];
}
