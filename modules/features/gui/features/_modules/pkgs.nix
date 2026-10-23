{
  self,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages =
    with pkgs;
    with self.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    [
      kitty
      wl-clipboard
      stirling-pdf-desktop
      libreoffice
      transmission_4
      transmission_4-gtk
      gparted
      pwvucontrol
      alsa-utils
      virt-manager
      obs-studio
      gimp
      freecad
      bruno
      telegram-desktop
      vscode
    ]
    ++ [
      openspec
      droid
    ]
    ++ lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [
      spotify
      discord
      zoom-us
      slack
      unstable.devin-desktop
    ];
}
