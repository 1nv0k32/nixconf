{
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    runGarbageCollection = true;
    upgrade = true;
    flags = [
      "--no-write-lock-file"
      "-L"
    ];
  };
}
