{ lib, ... }:
{
  options.environment.sysConf = {
    user = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "rick";
        description = "The main user of the system";
      };
      sshPubKeys = lib.mkOption {
        type = lib.types.listOf lib.types.singleLineStr;
        default = [
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINGeXe8VqajOuRf+0LECYQWMmaIee5shvMgiq3XOLNvoAAAABnNzaDo1Yw== rick@nyx" # 5c
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAICjS+ZPa4qUA+Vm0C7Br8PJ/U1Z9dh6bXcXZdko3ZFz9AAAAB3NzaDpiaW8= rick@nyx" # bio
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHn0AqWzb6VBqaJX7miDeuvxwlzfG3+UbKOyMlQQTz3r rick@nyx" # local
        ];
        description = "The main user's trusted SSH key";
      };
      yubikeyU2F = lib.mkOption {
        type = lib.types.str;
        default =
          let
            key_5c = "b2iecx1K5cZe7Y0mK1QoSExxzd05RNkG8rQcY+2Eqi5PgrudhFVe3dJd3olkA6zh9mYrEfOHMaXsahFLauaXsA==,DsrO0lWQeBujzQj10hyPDiL0fgEdv+h+qoMuTVpmdc8osRjwFhGR3pGDtEycjKGOc2E58ZaSZ6stvQIDyre8CQ==,es256,";
            key_bio = "7wwRJCaiRcL/HwR8JK7hdITpvcsX55jKDtY7ckBhUB00p8Id2s5AykzVPq79dbKvkiQhhcrQvd3bT1w3x16Nyw==,ijaKeTEL3VG81mm+0zi0XxZe8uXbcR8j8Rr/oZZGn3FbpTlWm+5wRyYjx0hPz02Ve8QyspXg935VnHl8lRMahw==,es256,+presence";
          in
          ''
            ${key_5c}:${key_bio}
          '';
      };
    };

    git = {
      username = lib.mkOption {
        type = lib.types.str;
        default = "Armin Mahdilou";
        description = "The name to use for git commits";
      };
      email = lib.mkOption {
        type = lib.types.str;
        default = "Armin.Mahdilou@gmail.com";
        description = "The email to use for git commits";
      };
    };

    gui = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };

    server = {
      sshPort = lib.mkOption {
        type = lib.types.int;
        default = 2222;
      };
    };
  };
}
