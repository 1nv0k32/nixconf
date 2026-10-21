{
  flake.nixosModules.sdr =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      gui = config.environment.sysConf.gui.enable;
      cliWrapped = pkgs.symlinkJoin {
        name = "sdrCliTools";
        paths = with pkgs; [
          uhd
          soapysdr-with-plugins
        ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          cp -r --remove-destination ${./uhd}/* "$out/share/uhd/images"
          for bin in $out/bin/*; do
            wrapProgram "$bin" \
              --set UHD_IMAGES_DIR "$out/share/uhd/images"
          done
        '';
      };
      guiWrapped = pkgs.symlinkJoin {
        name = "sdrGuiTools";
        paths = with pkgs; [
          gnuradio
          gqrx
          sdrpp
          qradiolink
          sdrangel
        ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          for bin in $out/bin/*; do
            wrapProgram "$bin" \
              --set UHD_IMAGES_DIR "${cliWrapped}/share/uhd/images"
          done
        '';
      };
    in
    {
      environment.systemPackages = [
        cliWrapped
      ]
      ++ lib.optionals gui [
        guiWrapped
      ];

      services.udev.packages = with pkgs; [
        uhd
      ];
    };
}
