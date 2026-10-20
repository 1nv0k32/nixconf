{ inputs, mkSystem, ... }:
let
  nixosModule =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.environment.sysConf;
    in
    {
      wsl = {
        enable = true;
        startMenuLaunchers = true;
        defaultUser = cfg.user.name;
        extraBin = with pkgs; [
          { src = "${lib.getExe wget}"; }
          { src = "${lib.getExe curl}"; }
        ];
        wslConf = {
          user.default = cfg.user.name;
          boot.systemd = true;
        };
      };

      programs = {
        nix-ld = {
          enable = true;
          libraries = with pkgs; [
            libgcc
            zlib
            pcre2
          ];
        };
      };

      services.resolved.enable = lib.mkForce false;
      boot = {
        loader.systemd-boot.enable = lib.mkForce false;
        initrd.systemd.enable = lib.mkForce false;
        binfmt.emulatedSystems = lib.mkForce [ ];
      };
    };
in
{
  flake.nixosModules.systemTypes.wsl = mkSystem {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-wsl.nixosModules.wsl
      nixosModule
    ];
  };
}
