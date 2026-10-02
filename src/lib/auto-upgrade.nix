{
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    runGarbageCollection = true;
    flags = [
      "--no-write-lock-file"
      "-L"
    ];
  };
}
