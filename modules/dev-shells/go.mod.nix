{
  perSystem =
    { pkgs, ... }:
    {
      devShells.go = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          libcap
          go
          gcc
          delve
        ];
        NIX_HARDENING_ENABLE = "";
      };
    };
}
