{
  perSystem =
    { pkgs, ... }:
    let
      bashOpts = ''
        set -euo pipefail
      '';
      krun = pkgs.writeShellScriptBin "k.run" ''
        ${bashOpts}
        qemu-system-x86_64 \
        -kernel linux/arch/x86/boot/bzImage \
        -initrd initramfs.img \
        -enable-kvm -machine pc-q35-7.1 \
        -m 2G -smp 1,sockets=1,cores=1 \
        -net nic,model=e1000 \
        -nographic -serial mon:stdio \
        -s -append 'console=ttyS0 earlyprintk=serial net.ifnames=0 nokaslr'
      '';
      kinit = pkgs.writeShellScriptBin "k.init" ''
        ${bashOpts}
        INITRAMFS_DIR=initramfs
        BUSYBOX_DIR=busybox
        LINUX_DIR=linux

        cat <<-EOF > $INITRAMFS_DIR/init
        #!/bin/sh
        mkdir -p /dev
        mkdir -p /proc
        mkdir -p /sys
        mount -t devtmpfs devtmpfs /dev
        mount -t proc none /proc
        mount -t sysfs none /sys
        exec env HOME=/root /bin/sh -l
        EOF
        chmod +x $INITRAMFS_DIR/init
        mkdir -p $INITRAMFS_DIR/root
        cat <<-EOF > $INITRAMFS_DIR/root/.profile
        alias ll='ls -alh --group-directories-first'
        EOF

        (
          cd $BUSYBOX_DIR
          make
          make CONFIG_PREFIX=../$INITRAMFS_DIR install
        )
        (
          cd $LINUX_DIR
          make INSTALL_MOD_PATH=../$INITRAMFS_DIR modules_install
        )
        (
          cd $INITRAMFS_DIR
          find . -print | cpio -H newc -o > ../initramfs.img
        )
      '';
    in
    {
      devShells.kernel = pkgs.mkShell {
        nativeBuildInputs =
          with pkgs;
          [
            stdenv.cc.libc
            stdenv.cc.libc.static
            flex
            bison
            bc
            elfutils
            openssl
            pkg-config
            ncurses
            gnumake
            git
            cpio
            qemu
            ctags
            cscope
            gdb
            autoconf
            automake
            # scripts
            kinit
            krun
          ]
          ++ (with pkgs.llvmPackages; [
            llvm
            libllvm
            clang
            clang-tools
            lld
          ]);
        NIX_HARDENING_ENABLE = "";
        shellHook = ''
          echo "Kernel development shell"
          JOBS=$([[ $(nproc) -gt 4 ]] && echo $(( $(nproc) - 4 )))
          export MAKEFLAGS="--jobs=$JOBS"
          echo "Base make jobs: $JOBS"
        '';
      };
    };
}
