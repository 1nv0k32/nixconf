{
  flake.nixosModules.nix-serve =
    { ... }:
    {
      services.nix-serve = {
        enable = true;
        openFirewall = true;
      };
    };
}
