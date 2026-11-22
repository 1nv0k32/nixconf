{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.anonsurf;

  # Must match the TorrcPath patched into pkgs.anonsurf.
  torrcDir = "/etc/anonsurf/torrc.d";

  renderValue =
    value:
    if lib.isBool value then
      lib.boolToString value
    else if lib.isList value then
      builtins.toJSON (lib.concatMapStringsSep "," toString value)
    else
      builtins.toJSON value;

  configFile = pkgs.writeText "anonsurf.cfg" (
    "[AnonSurfConfig]\n"
    + lib.concatStrings (
      lib.mapAttrsToList (name: value: "${name}=${renderValue value}\n") cfg.settings
    )
  );

  bridgesFile =
    if cfg.bridges == null then
      "${cfg.package}/etc/anonsurf/bridges.txt"
    else
      pkgs.writeText "anonsurf-bridges.txt" (lib.concatLines cfg.bridges);

  mkBoolOption =
    description:
    lib.mkOption {
      type = lib.types.bool;
      default = false;
      inherit description;
    };
in
{
  options.services.anonsurf = {
    enable = lib.mkEnableOption ''
      AnonSurf, which routes all TCP traffic and DNS lookups of this machine
      through Tor while {command}`anonsurf start` is active.
      This also enables {option}`services.tor.enable` and requires NetworkManager'';

    package = lib.mkPackageOption pkgs "anonsurf" { };

    gui = {
      enable = lib.mkEnableOption "the AnonSurf Qt interface";
      package = lib.mkPackageOption pkgs "anonsurf-gui" { };
    };

    startOnBoot = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to start routing traffic through Tor at boot.
        {command}`anonsurf boot enable` cannot change this on NixOS,
        since systemd units are managed declaratively.
      '';
    };

    bridges = lib.mkOption {
      type = with lib.types; nullOr (listOf str);
      default = null;
      example = [
        "obfs4 192.0.2.1:443 0123456789ABCDEF0123456789ABCDEF01234567 cert=... iat-mode=0"
      ];
      description = ''
        Bridge lines that AnonSurf picks from when
        [](#opt-services.anonsurf.settings.auto_bridge) is enabled.
        `null` uses the default bridges shipped with AnonSurf.
      '';
    };

    settings = lib.mkOption {
      default = { };
      description = ''
        Configuration written to {file}`/etc/anonsurf/anonsurf.cfg`.
        AnonSurf renders these into the torrc fragment it adds to
        {option}`services.tor` while routing is active.
      '';
      type = lib.types.submodule {
        options = {
          use_sandbox = mkBoolOption "Whether to enable Tor's `Sandbox` option.";
          use_safe_sock = mkBoolOption "Whether to enable Tor's `SafeSocks` option.";

          bridge_address = lib.mkOption {
            type = lib.types.str;
            default = "";
            example = "obfs4 192.0.2.1:443 0123456789ABCDEF0123456789ABCDEF01234567 cert=... iat-mode=0";
            description = ''
              A single bridge line to connect through. `obfs4` and `snowflake`
              bridges are supported. Ignored when
              [](#opt-services.anonsurf.settings.auto_bridge) is enabled.
            '';
          };

          auto_bridge = mkBoolOption ''
            Whether to connect through three random bridges from
            [](#opt-services.anonsurf.bridges).
          '';

          reject_plain_port = mkBoolOption ''
            Whether to reject connections to
            [](#opt-services.anonsurf.settings.list_plain_ports) instead of only
            warning about them.
          '';

          list_plain_ports = lib.mkOption {
            type = with lib.types; nonEmptyListOf port;
            default = [
              23
              109
              110
              143
            ];
            description = "Plaintext ports passed to Tor's `WarnPlaintextPorts` or `RejectPlaintextPorts`.";
          };

          http_proxy_address = lib.mkOption {
            type = lib.types.str;
            default = "";
            example = "192.0.2.1:3128";
            description = "Upstream HTTP(S) proxy Tor connects through.";
          };

          http_proxy_credential = lib.mkOption {
            type = lib.types.str;
            default = "";
            example = "user:password";
            description = ''
              Credentials for the upstream proxy. Requires
              [](#opt-services.anonsurf.settings.proxy_is_https).
              The value is stored in the world-readable Nix store.
            '';
          };

          proxy_is_https = mkBoolOption "Whether the upstream proxy is an HTTPS proxy.";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.networking.networkmanager.enable;
        message = "services.anonsurf requires networking.networkmanager.enable, as it switches DNS through NetworkManager.";
      }
      {
        assertion = !config.services.tor.client.transparentProxy.enable;
        message = "services.anonsurf provides its own Tor TransPort on 127.0.0.1:9040; disable services.tor.client.transparentProxy.enable.";
      }
      {
        assertion = !config.services.tor.client.dns.enable;
        message = "services.anonsurf provides its own Tor DNSPort on 127.0.0.1:9053; disable services.tor.client.dns.enable.";
      }
      {
        assertion = cfg.settings.http_proxy_credential == "" || cfg.settings.proxy_is_https;
        message = "services.anonsurf.settings.http_proxy_credential requires services.anonsurf.settings.proxy_is_https.";
      }
    ];

    environment.systemPackages = [ cfg.package ] ++ lib.optional cfg.gui.enable cfg.gui.package;

    environment.etc = {
      "anonsurf/anonsurf.cfg" = {
        source = configFile;
        mode = "0600";
      };
      "anonsurf/bridges.txt".source = bridgesFile;
      "anonsurf/onion.pac".source = "${cfg.package}/etc/anonsurf/onion.pac";
      # anondaemon rewrites this file unless it already has the expected content.
      "anonsurf/nyxrc".source = "${cfg.package}/etc/anonsurf/nyxrc";
    };

    services.tor = {
      enable = true;
      # While routing is active, anondaemon writes its torrc fragment here
      # and restarts tor.service; the directory is empty otherwise.
      settings."%include" = [ torrcDir ];
    };

    systemd.packages = [ cfg.package ];

    # tor fails on a missing %include path, and tmpfiles is reapplied before
    # services are restarted on switch. setgid keeps the fragment readable by
    # Tor, which does not run as root.
    systemd.tmpfiles.settings.anonsurf.${torrcDir}.d = {
      mode = "2750";
      user = "root";
      group = "tor";
    };

    systemd.services.tor = {
      wants = [ "anonsurf-recovery.service" ];
      after = [ "anonsurf-recovery.service" ];
    };

    systemd.services.anonsurf-recovery.wantedBy = [ "multi-user.target" ];
    systemd.services.anonsurfd.wantedBy = lib.mkIf cfg.startOnBoot [ "multi-user.target" ];
  };

  meta.maintainers = with lib.maintainers; [ _1nv0k32 ];
}
