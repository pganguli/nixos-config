{ pkgs, ... }: {
  # Power diagnostics (run with sudo)
  environment.systemPackages = [ pkgs.powertop pkgs.linuxPackages.turbostat ];

  # Settings that powertop's Tunables tab reports as "Bad"
  boot.kernel.sysctl = {
    "kernel.nmi_watchdog" = 0;                # no periodic NMI wakeups (no hard-lockup detection)
    "vm.dirty_writeback_centisecs" = 1500;    # write dirty pages every 15 s, not 5 s
  };

  # Battery levels and the action at critical battery
  services.upower = {
    enable = true;
    percentageLow = 15;
    percentageCritical = 5;
    percentageAction = 3;
    criticalPowerAction = "Hibernate";
  };

  # "Suspend, then hibernate": hibernate after 2 hours of suspend
  systemd.sleep.settings.Sleep.HibernateDelaySec = "2h";

  # Mute the speakers before suspend or hibernate
  systemd.services.mute-before-sleep = {
    description = "Mute audio before sleep";
    before = [ "sleep.target" ];
    wantedBy = [ "sleep.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      uid=$(${pkgs.coreutils}/bin/id -u pganguli)
      if [ -S "/run/user/$uid/pipewire-0" ]; then
        ${pkgs.util-linux}/bin/runuser -u pganguli -- \
          env XDG_RUNTIME_DIR="/run/user/$uid" \
          ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ 1
      fi
    '';
  };

  # Restart WirePlumber after resuming from hibernation. The Bluetooth adapter
  # re-initializes on resume, and WirePlumber can lose the race to re-register
  # its A2DP endpoints, falling back to the legacy BlueZ API ("only SBC will be
  # supported"). Headphones are then stuck on the mono headset profile (HFP).
  systemd.services.restart-wireplumber-after-hibernate = {
    description = "Restart WirePlumber after hibernation so Bluetooth A2DP works";
    after = [ "hibernate.target" "suspend-then-hibernate.target" "hybrid-sleep.target" ];
    wantedBy = [ "hibernate.target" "suspend-then-hibernate.target" "hybrid-sleep.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      uid=$(${pkgs.coreutils}/bin/id -u pganguli)
      [ -S "/run/user/$uid/pipewire-0" ] || exit 0
      # Wait (up to 20 s) for the Bluetooth adapter to power back on
      for _ in $(${pkgs.coreutils}/bin/seq 20); do
        ${pkgs.bluez}/bin/bluetoothctl show | ${pkgs.gnugrep}/bin/grep -q "Powered: yes" && break
        ${pkgs.coreutils}/bin/sleep 1
      done
      ${pkgs.systemd}/bin/systemctl --user -M pganguli@ restart wireplumber.service
    '';
  };

  # Bluetooth (for Bluetooth headphones and the audio profile switch)
  hardware.bluetooth.enable = true;
}
