{ lib, ... }:
{
  fileSystems."/" = lib.mkForce {
    device = "none";
    fsType = "ext4";
  };
}
