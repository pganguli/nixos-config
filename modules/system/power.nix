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

  # Bluetooth (for Bluetooth headphones and the audio profile switch)
  hardware.bluetooth.enable = true;
}
