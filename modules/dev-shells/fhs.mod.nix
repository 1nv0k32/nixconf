{
  perSystem =
    { lib, pkgs, ... }:
    let
      LD_LIBRARY_PATH =
        with pkgs;
        lib.makeLibraryPath [
          stdenv.cc.cc
          zlib
          ncurses5
          pixman
          libpng
          libtinfo
          libxcrypt-legacy
        ];
    in
    {
      devShells.fhs =
        (pkgs.buildFHSEnv {
          name = "fhs";
          targetPkgs =
            pkgs:
            (with pkgs; [
              # basics
              coreutils
              bash
              gcc
              unzip
              nettools
              ncurses5
              zlib
              # python
              uv
              python312
              # go
              libcap
              go
              gcc
              delve
              # platformio
              platformio-core
              openocd
              arduino-cli
              avrdude
              libftdi
              libftdi1
              libusb1
              # vivado
              libuuid
              libxext
              libx11
              libxrender
              libxtst
              libxi
              libxft
              libxcb
              freetype
              fontconfig
              glib
              gtk2
              gtk3
              graphviz
            ]);

          NIX_HARDENING_ENABLE = "";
          LD_LIBRARY_PATH = LD_LIBRARY_PATH;

          runScript = ''
            env LIBRARY_PATH=/usr/lib \
            C_INCLUDE_PATH=/usr/include \
            CPLUS_INCLUDE_PATH=/usr/include \
            CMAKE_LIBRARY_PATH=/usr/lib \
            CMAKE_INCLUDE_PATH=/usr/include \
            LD_LIBRARY_PATH=${LD_LIBRARY_PATH} \
            ${lib.getExe pkgs.zsh}
          '';
        }).env;
    };
}
