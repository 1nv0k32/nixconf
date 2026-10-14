# NixOS

## Installation

```sh
nixos-rebuild boot --no-write-lock-file --flake "git+https://codeberg.org/1nv0k32/nixconf?dir=flakes#HOST"
```

## nixos-anywhere

```sh
nix-shell -p nixos-anywhere
nixos-anywhere --build-on remote --flake "git+https://codeberg.org/1nv0k32/nixconf?dir=flakes#HOST" root@HOST
```

## Download target flake

```sh
wget https://codeberg.org/1nv0k32/nixconf/raw/branch/main/flakes/flake.nix
```

## Build for other hosts

```sh
nix build \
    --no-write-lock-file \
    --print-build-logs \
    --no-link \
    "git+https://codeberg.org/1nv0k32/nixconf?dir=flakes#nixosConfigurations.HOST.config.system.build.toplevel"
```
