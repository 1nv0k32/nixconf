{
  inputs = {
    cfg = {
      url = "git+https://codeberg.org/1nv0k32/nixconf";
    };
  };

  outputs =
    { cfg, ... }:
    with cfg.nixosModules;
    let
      mkHost =
        host: attrib:
        attrib.systemType {
          hostName = host;
          domain = attrib.domain;
          modules = [
            ./hardware-configuration.nix
            ./local.nix
          ];
        };
    in
    {
      nixosConfigurations = builtins.mapAttrs mkHost {
        nyx = {
          domain = "nyxlan.internal";
          systemType = systemTypes.z13g2;
        };
        nyxpi = {
          domain = "nyxlan.internal";
          systemType = systemTypes.rpi5;
        };
        nyxmac = {
          domain = null;
          systemType = systemTypes.mac;
        };
        nyxdroid = {
          domain = null;
          systemType = systemTypes.avf;
        };
        nyxwsl = {
          domain = null;
          systemType = systemTypes.wsl;
        };
        # VMs
        nyxvm = {
          domain = null;
          systemType = systemTypes.qemu;
        };
        nyxutm = {
          domain = null;
          systemType = systemTypes.utm;
        };
        nyxprl = {
          domain = null;
          systemType = systemTypes.parallels;
        };
      };
      darwinConfigurations = builtins.mapAttrs mkHost {
        nyxdarwin = {
          domain = null;
          systemType = systemTypes.darwin;
        };
      };
    };
}
