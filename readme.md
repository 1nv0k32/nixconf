# NixOS

## Installation

```sh
nixos-rebuild boot --impure --no-write-lock-file --flake "git+https://codeberg.org/1nv0k32/nixconf#HOST"
```

## nixos-anywhere

```sh
nix-shell -p nixos-anywhere
nixos-anywhere --build-on remote --flake "git+https://codeberg.org/1nv0k32/nixconf#HOST" root@HOST
```

## Build for other hosts

```sh
nix build \
    --no-write-lock-file \
    --print-build-logs \
    --no-link \
    "git+https://codeberg.org/1nv0k32/nixconf#nixosConfigurations.HOST.config.system.build.toplevel"
```

## Run devShells or pkgs

```sh
nix develop "git+https://codeberg.org/1nv0k32/nixconf#SHELL"
```

```sh
nix run "git+https://codeberg.org/1nv0k32/nixconf#PKG"
```
