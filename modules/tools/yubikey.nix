{ pkgs, lib, ... }:
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
      };
      u2f.settings = {
        cue = true;
        userpresence = 0;
        authfile = "/etc/u2f_mappings";
      };
    };
  };
}
