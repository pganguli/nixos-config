{ pkgs, ... }: {
  # Bench instruments and TI debug probes: let the logged-in user open them
  # without root (the "uaccess" tag). The MSP430 probes are in msp430.nix.
  # Not in services.udev.extraRules: that is 99-local.rules, which runs after
  # 73-seat-late.rules, and that is where the tag turns into a permission for
  # the logged-in user. So the rules go in a package, as 70-*.rules.
  services.udev.packages = [ (pkgs.writeTextDir "lib/udev/rules.d/70-lab-instruments.rules" ''
    # Joulescope
    SUBSYSTEM=="usb", ATTRS{idVendor}=="16d0", TAG+="uaccess"
    # PicoScope
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0ce9", TAG+="uaccess"
    # BK Precision
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2ec7", ATTRS{idProduct}=="9130", TAG+="uaccess"
    # USBTMC instruments
    KERNEL=="usbtmc[0-9]*", TAG+="uaccess"

    # TI Code Composer Studio emulators
    # Blackhawk
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0b1e", TAG+="uaccess"
    # Spectrum Digital XDS
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0c55", TAG+="uaccess"
    # TI XDS100/110/200 (FTDI- and Luminary-based)
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010|6011|a6d0|a6d1|bcd9|bcda", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1cbe", ATTRS{idProduct}=="00fd|00ff|02a5", TAG+="uaccess"
  '') ];
}
