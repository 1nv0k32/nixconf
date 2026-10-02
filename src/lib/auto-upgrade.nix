{
  system.autoUpgrade = {
    enable = true;
    flake = "/etc/nixos/flake.nix";
    allowReboot = true;
    runGarbageCollection = true;
    flags = [
      "--no-write-lock-file"
      "-L"
    ];
  };
}
