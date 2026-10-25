{
  self,
  lib,
  pkgs,
  ...
}:
let
  llmAgents = self.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  environment.systemPackages =
    with pkgs;
    [
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
      llmAgents.openspec
      llmAgents.droid
    ]
    ++ lib.optionals stdenv.hostPlatform.isx86_64 [
      spotify
      discord
      zoom-us
      slack
      unstable.devin-desktop
    ];
}
