{
  flake.nixosModules.shells =
    { lib, pkgs, ... }:
    {
      imports = [
        ./bash.nix
        ./zsh.nix
      ];

      users.defaultUserShell = pkgs.zsh;

      environment.shellAliases = {
        rm = "rm -I";
        ls = "ls --color=auto";
        ll = "ls -alhFb --group-directories-first";
        grep = "${lib.getExe pkgs.gnugrep} --color=auto";
        diff = "${pkgs.diffutils}/bin/diff --color=auto";
        cat = "${lib.getExe pkgs.bat} -p";
      };
    };
}
