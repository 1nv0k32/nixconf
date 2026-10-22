{ lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ddcutil-service
    ddcutil
    ddccontrol
  ];

  boot.kernelModules = [ "i2c-dev" ];
  services.udev.extraRules = lib.mkAfter ''
    KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
  '';
}
