{ lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gns3-gui
    gns3-server
    dynamips
    inetutils
  ];

  security.wrappers.ubridge = {
    source = "${lib.getExe pkgs.ubridge}";
    capabilities = "cap_net_admin,cap_net_raw=ep";
    owner = "root";
    group = "ubridge";
    permissions = "u+rx,g+x";
  };
}
