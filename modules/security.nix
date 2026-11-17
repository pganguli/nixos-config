{ lib, pkgs, ... }: {
  # ---------- SSH client agent ----------
  # One ssh-agent per login (systemd user service, socket $XDG_RUNTIME_DIR/ssh-agent).
  # Plasma sets ksshaskpass as the password dialog; it can keep the passphrase in KWallet.
  programs.ssh.startAgent = true;

  # ---------- GnuPG ----------
  # gpg-agent with the Qt password dialog. SSH keys stay with ssh-agent.
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-qt;
    enableSSHSupport = false;
  };

  # ---------- SSH server (on demand) ----------
  # Installed and configured, but not started at boot.
  #   Start:  sudo systemctl start sshd
  #   Stop:   sudo systemctl stop sshd
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;        # keys only
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "pganguli" ];
    };
  };
  systemd.services.sshd.wantedBy = lib.mkForce [ ];
}
