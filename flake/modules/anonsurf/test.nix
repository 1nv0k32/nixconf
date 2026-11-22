{ lib, ... }:

let
  bridge = "obfs4 192.0.2.1:443 0123456789ABCDEF0123456789ABCDEF01234567 cert=dGVzdA iat-mode=0";
in
{
  name = "anonsurf";
  meta.maintainers = with lib.maintainers; [ _1nv0k32 ];

  nodes.machine =
    { pkgs, ... }:
    {
      networking.networkmanager.enable = true;
      environment.systemPackages = [ pkgs.iptables ];

      services.anonsurf = {
        enable = true;
        gui.enable = true;
        settings = {
          use_safe_sock = true;
          reject_plain_port = true;
          list_plain_ports = [
            23
            110
          ];
        };
      };

      specialisation.bridge.configuration.services.anonsurf.settings.bridge_address = bridge;
    };

  testScript =
    { nodes, ... }:
    let
      torUid = toString nodes.machine.ids.uids.tor;
    in
    ''
      import json

      fragment = "/etc/anonsurf/torrc.d/anonsurf.conf"

      def status():
          return json.loads(machine.succeed("anonsurf status --json"))

      machine.wait_for_unit("multi-user.target")
      machine.wait_for_unit("tor.service")
      machine.wait_for_unit("anonsurf-recovery.service")
      machine.wait_until_succeeds("grep -q nameserver /etc/resolv.conf")
      machine.fail("systemctl is-active anonsurfd.service")
      machine.succeed("stat -c '%U:%G %a' /etc/anonsurf/torrc.d | grep -x 'root:tor 2750'")
      machine.succeed("stat -c '%a' /etc/anonsurf/anonsurf.cfg | grep -x 600")

      resolv_before = machine.succeed("cat /etc/resolv.conf")
      assert status()["anonsurf_active"] is False

      with subtest("start routes traffic through Tor"):
          machine.succeed("anonsurf start")
          machine.wait_for_unit("anonsurfd.service")
          machine.wait_for_unit("tor.service")

          conf = machine.succeed(f"cat {fragment}")
          assert "SafeSocks 1" in conf, conf
          assert "RejectPlaintextPorts 23,110" in conf, conf
          assert "RunAsDaemon" not in conf, conf
          machine.succeed(f"stat -c '%U:%G %a' {fragment} | grep -x 'root:tor 640'")

          # Probe listeners with ss: tor 0.4.9.16 segfaults when a direct,
          # non-redirected connection reaches its TransPort during bootstrap.
          machine.wait_until_succeeds("ss -Hltn | grep -q 127.0.0.1:9040")
          machine.wait_until_succeeds("ss -Hltn | grep -q 127.0.0.1:9051")
          machine.wait_until_succeeds("ss -Hlun | grep -q 127.0.0.1:9053")

          nat = machine.succeed("iptables-save -t nat")
          assert "--uid-owner ${torUid} -j RETURN" in nat, nat
          assert "REDIRECT --to-ports 9040" in nat, nat
          assert "REDIRECT --to-ports 9053" in nat, nat

          machine.succeed("grep -x 'nameserver 127.0.0.1' /etc/resolv.conf")
          machine.succeed("grep -x 1 /proc/sys/net/ipv6/conf/all/disable_ipv6")

          s = status()
          assert s["anonsurf_active"] and s["tor_active"] and s["dns_state"] == "tor", s

      with subtest("changeid talks to the Tor control port"):
          machine.succeed("anonsurf changeid")
          machine.succeed("systemctl is-active tor.service")

      with subtest("restart regenerates the Tor configuration"):
          machine.succeed("anonsurf restart")
          machine.wait_for_unit("anonsurfd.service")
          machine.wait_until_succeeds("ss -Hltn | grep -q 127.0.0.1:9040")

      with subtest("stop restores the original network"):
          machine.succeed("anonsurf stop")
          machine.fail("systemctl is-active anonsurfd.service")
          machine.fail(f"test -e {fragment}")
          nat = machine.succeed("iptables-save -t nat")
          assert "REDIRECT" not in nat, nat
          assert machine.succeed("cat /etc/resolv.conf") == resolv_before
          machine.succeed("grep -x 0 /proc/sys/net/ipv6/conf/all/disable_ipv6")
          machine.wait_for_unit("tor.service")
          machine.wait_until_fails("ss -Hltn | grep -q 127.0.0.1:9040")

      with subtest("obfs4 bridges launch lyrebird inside the Tor sandbox"):
          machine.succeed("/run/current-system/specialisation/bridge/bin/switch-to-configuration test")
          machine.succeed("anonsurf start")
          conf = machine.succeed(f"cat {fragment}")
          assert "UseBridges 1" in conf, conf
          assert "Bridge ${bridge}" in conf, conf
          machine.succeed(f"grep -E '^ClientTransportPlugin obfs4 exec /nix/store/[^ ]+/bin/lyrebird managed$' {fragment}")
          machine.wait_until_succeeds("pgrep -u tor lyrebird")
          machine.succeed("anonsurf stop")
          machine.fail(f"test -e {fragment}")

      with subtest("GUI starts"):
          machine.succeed("QT_QPA_PLATFORM=offscreen timeout 10 anonsurf-gui || test $? -eq 124")
    '';
}
