{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  nixosTests,
  bleachbit,
  iptables,
  networkmanager,
  nyx,
  obfs4,
  procps,
  snowflake,
  systemd,
}:

buildGoModule (finalAttrs: {
  pname = "anonsurf";
  version = "6.0.1";

  src = fetchFromGitHub {
    owner = "ParrotSec";
    repo = "anonsurf";
    tag = "debian/${finalAttrs.version}+parrot2";
    hash = "sha256-lJ8xSV0XQWzTj94MyzZ8gjfLyNSKa3i9WQrzSq3LFZ4=";
  };

  modRoot = "src";
  vendorHash = null;

  subPackages = [
    "cmd/anondaemon"
    "cmd/anonsurf-cli"
    "cmd/dnstool"
    "cmd/make-torrc"
    "cmd/safekill"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  # Upstream targets Debian's tor@default.service, which reads /etc/tor/torrc.
  # On NixOS, tor.service reads a store torrc that %includes the directory
  # anonsurf writes its torrc into (see nixos/modules/services/security/anonsurf.nix).
  postPatch = ''
    substituteInPlace src/internal/anonsurf/client.go \
      --replace-fail '"/usr/lib/anonsurf/anondaemon"' "\"$out/lib/anonsurf/anondaemon\""
    # sudo must be the host's setuid wrapper, so resolve it through PATH.
    substituteInPlace src/internal/command/privilege.go \
      --replace-fail '"/usr/bin/sudo"' '"sudo"'
    substituteInPlace src/internal/systemd/service.go \
      --replace-fail '"/usr/bin/systemctl"' '"${lib.getExe' systemd "systemctl"}"' \
      --replace-fail '"tor@default.service"' '"tor.service"'
    substituteInPlace src/internal/firewall/manager.go \
      --replace-fail '"/usr/sbin/iptables-save"' '"${lib.getExe' iptables "iptables-save"}"' \
      --replace-fail '"/usr/sbin/iptables-restore"' '"${lib.getExe' iptables "iptables-restore"}"' \
      --replace-fail '"debian-tor"' '"tor"'
    substituteInPlace src/internal/ipv6/manager.go \
      --replace-fail '"/sbin/sysctl"' '"${lib.getExe' procps "sysctl"}"'
    substituteInPlace src/internal/dns/nm.go \
      --replace-fail '"/usr/bin/nmcli"' '"${lib.getExe' networkmanager "nmcli"}"'
    substituteInPlace src/internal/monitor/nyx.go \
      --replace-fail '"/usr/bin/nyx"' '"${lib.getExe nyx}"'
    substituteInPlace src/internal/safekill/safekill.go \
      --replace-fail '"/usr/bin/bleachbit"' '"${lib.getExe bleachbit}"'
    substituteInPlace src/internal/tor/bridge_resolver.go \
      --replace-fail 'lookupExecutablePath("obfs4proxy")' 'lookupExecutablePath("${lib.getExe obfs4}")' \
      --replace-fail 'lookupExecutablePath("snowflake-client")' 'lookupExecutablePath("${lib.getExe' snowflake "client"}")'

    substituteInPlace src/internal/tor/torrc_manager.go \
      --replace-fail '"/etc/tor/torrc"' '"/etc/anonsurf/torrc.d/anonsurf.conf"' \
      --replace-fail 'fileops.WriteAtomic(TorrcPath, []byte(content), 0600)' \
                     'fileops.WriteAtomic(TorrcPath, []byte(content), 0640)'
    substituteInPlace src/internal/tor/identity.go \
      --replace-fail /var/run/tor/ /run/tor/
    # tor.service is Type=simple, its SOCKSPort is owned by services.tor.client,
    # and its sandbox cannot bind privileged ports.
    substituteInPlace src/internal/tor/assets/torrc.base \
      --replace-fail $'#daemonize\nRunAsDaemon 1\n' "" \
      --replace-fail $'SocksPort 127.0.0.1:9050 IsolateClientAddr IsolateSOCKSAuth IsolateClientProtocol IsolateDestPort IsolateDestAddr\n' "" \
      --replace-fail 'DNSPort 127.0.0.1:53' 'DNSPort 127.0.0.1:9053' \
      --replace-fail /var/run/tor/ /run/tor/

    substituteInPlace sys-units/*.service \
      --replace-fail /usr/lib/anonsurf "$out/lib/anonsurf" \
      --replace-quiet tor@default.service tor.service
    substituteInPlace debian/anonsurf.1 \
      --replace-fail /etc/tor/torrc /etc/anonsurf/torrc.d/anonsurf.conf
  '';

  postInstall = ''
    mv $out/bin/anonsurf-cli $out/bin/anonsurf
    mkdir -p $out/lib/anonsurf
    mv $out/bin/{anondaemon,make-torrc,safekill} $out/lib/anonsurf/

    install -Dm644 ../configs/{anonsurf.cfg,bridges.txt,onion.pac} -t $out/etc/anonsurf
    install -Dm644 ../src/internal/tor/assets/nyxrc -t $out/etc/anonsurf
    install -Dm644 ../sys-units/*.service -t $out/lib/systemd/system

    install -Dm644 ../gui/org.parrotsec.AnonsurfCli.desktop -t $out/share/applications
    install -Dm644 ../icons/anonsurf.png -t $out/share/icons/hicolor/512x512/apps

    installManPage ../debian/anonsurf.1
    installShellCompletion --cmd anonsurf --bash ../debian/anonsurf.bash-completion
    # The same file also registers dnstool; bash-completion loads files by command name.
    installShellCompletion --cmd dnstool --bash ../debian/anonsurf.bash-completion
  '';

  passthru.tests.nixos = nixosTests.anonsurf;

  meta = {
    description = "Anonymization toolkit that routes system traffic through Tor";
    longDescription = ''
      AnonSurf is Parrot OS's anonymization toolkit. It uses iptables to
      redirect TCP traffic and DNS lookups through Tor, disables IPv6 and can
      optionally close selected applications and clear their caches.

      This package is patched to work with the NixOS `tor.service`;
      enable it with `services.anonsurf.enable`.
    '';
    homepage = "https://gitlab.com/parrotsec/packages/anonsurf";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ _1nv0k32 ];
    mainProgram = "anonsurf";
    platforms = lib.platforms.linux;
  };
})
