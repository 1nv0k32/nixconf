{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  environment.systemPackages =
    with pkgs;
    [
      wl-clipboard
      networkmanagerapplet
      pwvucontrol
      qtpass
      stirling-pdf-desktop
      libreoffice
      transmission_4
      transmission_4-gtk
      gparted
      virt-manager
      obs-studio
      gimp
      freecad
      openscad
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
    ];
}
