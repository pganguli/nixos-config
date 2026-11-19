{ lib, ... }: {
  # ---------- Tailscale (on demand) ----------
  # Installed, but the daemon is not started at boot.
  #   Start:   sudo systemctl start tailscaled && sudo tailscale up
  #   Stop:    sudo tailscale down && sudo systemctl stop tailscaled
  # The first "tailscale up" prints a login link. The login is kept in
  # /var/lib/tailscale, so later starts need no login. To run "tailscale"
  # without sudo, run once: sudo tailscale set --operator=pganguli
  services.tailscale.enable = true;
  systemd.services.tailscaled.wantedBy = lib.mkForce [ ];
}
