{ pkgs, lib, ... }:
let
  # ---------- Phone tethering through TetherFuseNet ----------
  # TetherFuseNet on the phone offers a SOCKS5 proxy (port 8228) but does not
  # route raw IP. So when the laptop joins the phone, all traffic goes
  #   tun2proxy (tun0) -> phone SOCKS5 -> cellular
  #
  #   Wi-Fi Direct  NM profile "DIRECT-TF-NET_nomap"  phone = 192.168.49.1
  #   USB tether    NM profile "Tether"               phone = DHCP gateway (changes)
  #
  # A NetworkManager dispatcher script starts tun2proxy@<phone-ip>.service when
  # one of those profiles comes up and stops it when it goes down. Every other
  # network (eduroam, home Wi-Fi, ...) is left alone.
  #
  # The NM profiles themselves live in NetworkManager's state, not here. Re-apply
  # if they are ever recreated (no default route or IPv6 through the phone):
  #   nmcli con modify "DIRECT-TF-NET_nomap" ipv4.never-default yes ipv6.method disabled \
  #     802-11-wireless.powersave 2
  #   nmcli con modify "Tether" ipv4.never-default yes ipv6.method disabled
  #
  # Check it with:
  #   systemctl list-units 'tun2proxy@*'
  #   journalctl -b -t tun2proxy-dispatch    # what the dispatcher did
  #   journalctl -f -u 'tun2proxy@*'         # the tunnel itself
  # (not both flags in one journalctl: -t and -u together match nothing)
  socksPort = 8228;

  # NetworkManager profile names (nmcli -t -f NAME con show)
  wifiConn = "DIRECT-TF-NET_nomap";
  usbConn = "Tether";
  wifiPhoneFallback = "192.168.49.1";   # Android's Wi-Fi Direct group-owner address

  # No IPv6 on tun0 once tun2proxy has made it (stops IPv6-ICMP log noise)
  tun0NoIpv6 = pkgs.writeShellScript "tun0-no-ipv6" ''
    for _ in $(seq 20); do
      if [ -e /proc/sys/net/ipv6/conf/tun0 ]; then
        ${pkgs.procps}/bin/sysctl -qw net.ipv6.conf.tun0.disable_ipv6=1
        exit 0
      fi
      sleep 0.5
    done
  '';

  dispatch = pkgs.writeShellScript "tun2proxy-dispatch" ''
    export PATH=${lib.makeBinPath (with pkgs; [ coreutils iproute2 iw procps systemd util-linux ])}

    IFACE="$1"
    ACTION="$2"
    STATE_DIR=/run/tun2proxy-dispatch

    log() { logger -t tun2proxy-dispatch "$*"; }

    case "$CONNECTION_ID" in
      "${wifiConn}") KIND=wifi; FALLBACK="${wifiPhoneFallback}" ;;
      "${usbConn}")  KIND=usb;  FALLBACK="" ;;
      *) exit 0 ;;   # not a phone connection
    esac

    STATE_FILE="$STATE_DIR/$CONNECTION_UUID"

    # Phone address: DHCP gateway (first one), else NM's gateway, else the fallback
    PHONE="''${DHCP4_ROUTERS%% *}"
    [ -n "$PHONE" ] || PHONE="$IP4_GATEWAY"
    [ -n "$PHONE" ] || PHONE="$FALLBACK"

    # On top of the profile settings: no default route or IPv6 via the phone link
    harden() {
      for _ in 1 2 3 4 5; do
        ip -4 route del default dev "$IFACE" 2>/dev/null || break
      done
      sysctl -qw "net.ipv6.conf.$IFACE.disable_ipv6=1" 2>/dev/null || true
      if [ "$KIND" = wifi ]; then
        iw dev "$IFACE" set power_save off 2>/dev/null || true
      fi
    }

    case "$ACTION" in
      up|dhcp4-change)
        harden
        # NetworkManager runs this twice when the USB tether comes up, and the
        # first run has no phone address yet; the second one has it and starts
        # the tunnel. So no address is normal here: skip without logging.
        [ -n "$PHONE" ] || exit 0
        UNIT="tun2proxy@$PHONE.service"
        if ! systemctl is-active --quiet "$UNIT"; then
          # One tunnel at a time (both would want tun0): the newest connection wins
          systemctl stop 'tun2proxy@*.service'
          systemctl start --no-block "$UNIT"
          log "$CONNECTION_ID up on $IFACE: started $UNIT"
        fi
        mkdir -p "$STATE_DIR"
        echo "$UNIT" > "$STATE_FILE"
        ;;
      down)
        if [ -f "$STATE_FILE" ]; then
          UNIT="$(cat "$STATE_FILE")"
          systemctl stop --no-block "$UNIT"
          rm -f "$STATE_FILE"
          log "$CONNECTION_ID down on $IFACE: stopped $UNIT"
        fi
        ;;
    esac
  '';
in
{
  # Template unit, tun2proxy@<phone-ip>.service. Nothing wants it, so it never
  # starts at boot; only the dispatcher starts it. By hand:
  #   sudo systemctl start tun2proxy@<phone-ip>
  systemd.services."tun2proxy@" = {
    description = "tun2proxy via TetherFuseNet SOCKS5 at %i";
    unitConfig = {
      StartLimitIntervalSec = 60;
      StartLimitBurst = 10;
    };
    serviceConfig = {
      # DNS stays with systemd-resolved (DNS over TLS, see dns.nix), whose
      # encrypted lookups go through the tunnel like any other TCP. "direct"
      # passes DNS packets through untouched (no fake 198.18.x.x addresses).
      # --setup always mounts its own /etc/resolv.conf naming --dns-addr, so
      # point that at resolved's stub; otherwise apps that read resolv.conf
      # (browsers, Go programs) would skip resolved.
      ExecStart = "${pkgs.tun2proxy}/bin/tun2proxy-bin --setup"
        + " --proxy socks5://%i:${toString socksPort}"
        + " --dns direct"
        + " --dns-addr 127.0.0.53"
        + " --bypass %i/32";
      ExecStartPost = "-${tun0NoIpv6}";
      KillSignal = "SIGINT";     # like Ctrl-C: tun2proxy removes its routes
      TimeoutStopSec = 10;
      Restart = "on-failure";    # the phone's proxy may not be up yet at link-up
      RestartSec = 3;
    };
  };

  networking.networkmanager.dispatcherScripts = [
    { type = "basic"; source = dispatch; }
  ];
}
