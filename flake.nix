{
  # inputs are pinned by tack in ./.tack, update them with `tack update`
  outputs =
    { self, ... }:
    let
      inputs = removeAttrs (import ./.tack) [ "__functor" ] // {
        inherit self;
      };
      inherit (inputs.nixpkgs) lib;
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [
        (inputs.import-tree.filter (lib.hasInfix ".mod.") ./flake)
      ];

      perSystem =
        { pkgs, system, ... }:
        {
          # flake-parts derives pkgs from self.inputs, which tack leaves empty
          _module.args.pkgs = inputs.nixpkgs.legacyPackages.${system};

          formatter = pkgs.nixfmt-tree;
        };
    };
}
