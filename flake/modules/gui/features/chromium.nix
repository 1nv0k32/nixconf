{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.chromium ];

  programs.chromium = {
    enable = true;
    initialPrefs = {
      vertical_tabs = {
        enabled = true;
      };
    };
    extensions = [
      "nngceckbapebfimnlniiiahkandclblb" # bitwarden
      "ddkjiahejlhfcafbddmgiahcphecmpfh" # ublock origin lite
      "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # privacy badger
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # dark reader
      "dbepggeogbaibhgnhhndojpepiihcmeb" # vimium
      "pfnededegaaopdmhkdmcofjmoldfiped" # proxy switchy omega3
    ];
    extraOpts = {
      "RestoreOnStartup" = 1;
      "BrowserSignin" = 0;
      "SyncDisabled" = true;
      "PasswordManagerEnabled" = false;
      "BuiltInDnsClientEnabled" = false;
      "MetricsReportingEnabled" = true;
      "SpellcheckEnabled" = true;
      "SpellcheckLanguage" = [ "en-US" ];
      "CloudPrintSubmitEnabled" = false;
    };
  };
}
