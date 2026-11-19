{ ... }: {
  # ---------- Private DNS (DNS over TLS) ----------
  # Like Android's "Private DNS" in hostname mode: every lookup goes to
  # Cloudflare (one.one.one.one) over TLS, whatever network you are on, and
  # there is no fallback to plain DNS. The name after "#" is what the server's
  # certificate is checked against.
  #
  # "~." in Domains sends all names to these servers instead of to the DNS that
  # DHCP hands out (it is still used for names only that network knows).
  #
  # What this breaks, because strict mode refuses unencrypted DNS:
  #   - Wi-Fi with a login page (captive portal): the page's name won't resolve
  #     until you allow plain DNS. Temporarily:
  #       sudo resolvectl dnsovertls <interface> no
  #   - Campus names that only the VPN's DNS knows. Give the VPN profile its own
  #     setting (this profile is outside this config):
  #       nmcli connection modify "UNC VPN" connection.dns-over-tls no
  #
  # Check it with: resolvectl status   (look for "DNS over TLS: yes")
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = [
        "1.1.1.1#one.one.one.one"
        "1.0.0.1#one.one.one.one"
        "2606:4700:4700::1111#one.one.one.one"
        "2606:4700:4700::1001#one.one.one.one"
      ];
      DNSOverTLS = "yes";
      Domains = [ "~." ];
      FallbackDNS = [ ];   # empty: no built-in fallback servers
    };
  };
}
