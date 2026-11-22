{
  config,
  pkgs,
  lib,
  ...
}:
let
  yk-ssh-keygen = pkgs.writeShellScriptBin "yk-ssh-keygen" ''
    set -euo pipefail
    if [ "$#" -ne 1 ]; then
      echo "Usage: $0 <name>"
      exit 1
    fi
    ${pkgs.openssh}/bin/ssh-keygen -t ed25519-sk -O resident -O application="ssh:$1" -f "id_ed25519_sk_rk_$1"
  '';
in
{
  environment.systemPackages = with pkgs; [
    yk-ssh-keygen
    pam_u2f
    yubico-piv-tool
    yubikey-manager
    yubioath-flutter
  ];

  environment.etc.u2f_mappings.text = lib.mkDefault "";

  services = {
    pcscd.enable = true;
    udev.packages = with pkgs; [
      yubikey-personalization
    ];
    udev.extraRules = lib.mkAfter ''
      ACTION=="remove",\
      ENV{ID_BUS}=="usb",\
      ENV{ID_VENDOR_ID}=="1050",\
      ENV{ID_VENDOR}=="Yubico",\
      RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
    '';
  };

  security = {
    pam = {
      services = {
        login.u2fAuth = true;
        sudo.u2fAuth = true;
        polkit-1.u2fAuth = true;
      };
      u2f.settings = {
        cue = true;
        userpresence = 1;
        authfile = "/etc/u2f_mappings";
      };
    };
  };

  # polkit >= 127 runs PAM in a sandboxed unit with no /dev/hidraw*, so pam_u2f silently
  # falls through. nixpkgs 26.05 only opens it when security.pam.u2f.enable is global;
  # NixOS/nixpkgs#585509 fixes that on master.
  systemd.services."polkit-agent-helper@".serviceConfig =
    lib.mkIf (config.security.polkit.enable && config.security.pam.services.polkit-1.u2f.enable)
      {
        PrivateDevices = false;
        DeviceAllow = [
          "/dev/urandom r"
          "char-hidraw rw"
        ];
      };
}
