{
  inputs = {
    cfg = {
      url = "git+https://codeberg.org/1nv0k32/nixconf";
    };
  };

  outputs =
    { cfg, ... }:
    with cfg.nixosModules.systemTypes;
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
          systemType = z13g2;
        };
        nyxpi = {
          domain = "nyxlan.internal";
          systemType = rpi5;
        };
        nyxmac = {
          domain = null;
          systemType = mac;
        };
        nyxdroid = {
          domain = null;
          systemType = avf;
        };
        nyxwsl = {
          domain = null;
          systemType = wsl;
        };
        # VMs
        nyxvm = {
          domain = null;
          systemType = qemu;
        };
        nyxutm = {
          domain = null;
          systemType = utm;
        };
        nyxprl = {
          domain = null;
          systemType = parallels;
        };
      };
      darwinConfigurations = builtins.mapAttrs mkHost {
        nyxdarwin = {
          domain = null;
          systemType = darwin;
        };
      };
    };
}
