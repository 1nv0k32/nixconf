{
  perSystem =
    { pkgs, self', ... }:
    {
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = [
          self'.packages.nixconf
          self'.packages.nixup
        ];
      };
    };
}
