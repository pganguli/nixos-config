{ pkgs, ... }: {
  # Plasma and login screen
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Remove default apps that I do not use
  services.xserver.excludePackages = [ pkgs.xterm ];
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
    okular
    gwenview
    kate
    ktexteditor
    khelpcenter
    krdp
    qrca
    plasma-keyboard
    konsole
  ];

  # Printing
  services.printing.enable = true;

  # Sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Browser
  programs.firefox.enable = true;
}
