{ lib, ... }: {
  # ---------- Tailscale (on demand) ----------
  # Installed, but the daemon is not started at boot.
  #   Start:   sudo systemctl start tailscaled && sudo tailscale up
  #   Stop:    sudo tailscale down && sudo systemctl stop tailscaled
  # The first "tailscale up" prints a login link. The login is kept in
  # /var/lib/tailscale, so later starts need no login. To run "tailscale"
  # without sudo, run once: sudo tailscale set --operator=pganguli
  services.tailscale = {
    enable = true;
    # Opens UDP 41641 in the firewall, for direct connections between devices
    # (without it, traffic can fall back to Tailscale's relay servers). Nothing
    # listens on the port while tailscaled is stopped.
    openFirewall = true;
  };
  systemd.services.tailscaled.wantedBy = lib.mkForce [ ];
}
