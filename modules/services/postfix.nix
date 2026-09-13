{ config, lib, ... }:
{
  options = {
    environment.sysConf.postfixSaslPasswordPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "The postfix sasl password file path";
    };
  };

  config = {
    services.postfix = lib.mkIf (config.environment.sysConf.postfixSaslPasswordPath != null) {
      enable = true;
      relayHost = "smtp.gmail.com";
      relayPort = 587;
      config = {
        inet_interfaces = "localhost";
        smtp_bind_address = "127.0.0.1";
        smtp_sasl_auth_enable = "yes";
        smtp_sasl_security_options = "noanonymous";
        smtp_tls_security_level = "encrypt";
        smtp_sasl_password_maps = "texthash:${config.environment.sysConf.postfixSaslPasswordPath}";
      };
    };
  };
}
