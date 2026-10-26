{ lib, pkgs, ... }:
{
  environment.shellAliases = {
    k = "${lib.getExe pkgs.kubectl}";
  };

  programs = {
    kubeswitch.enable = true;
  };
}
