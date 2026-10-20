{
  perSystem =
    { pkgs, ... }:
    {
      devShells.python = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          uv
          python312
        ];

        buildInputs = with pkgs; [
          urh
        ];

        LD_LIBRARY_PATH =
          with pkgs;
          lib.makeLibraryPath [
            stdenv.cc.cc
            zlib
            zstd
          ];
      };
    };
}
