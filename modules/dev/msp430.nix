# TI's prebuilt msp430-elf GCC toolchain (nixpkgs' pkgsCross.msp430 does not evaluate).
# Both downloads are public; no click-through is needed.
# Use:  msp430-elf-gcc -mmcu=msp430g2553 -Os -o main.elf main.c
# The wrapper adds -I and -L for TI's device headers and linker scripts.
{ pkgs, lib, ... }:
let
  base = "http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSPGCC/9_3_1_2/export";

  msp430-gcc = pkgs.stdenv.mkDerivation {
    pname = "msp430-gcc";
    version = "9.3.1.11";

    srcs = [
      (pkgs.fetchurl {
        url = "${base}/msp430-gcc-9.3.1.11_linux64.tar.bz2";
        hash = "sha256-tghRthVl493SGTKYo/rFEgwkAllxdBBsxfhIK56ZhuY=";
      })
      (pkgs.fetchurl {
        url = "${base}/msp430-gcc-support-files-1.212.zip";
        hash = "sha256-Oxo58Qo0Tf77dn5grDW+zvTAZQE76GmTGVsTil+wuNY=";
      })
    ];
    sourceRoot = ".";

    nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.unzip pkgs.makeWrapper ];
    buildInputs = [ pkgs.stdenv.cc.cc.lib pkgs.zlib pkgs.ncurses5 pkgs.expat pkgs.gmp pkgs.mpfr pkgs.libmpc ];
    # gdb-py wants a specific Python, which TI does not ship
    autoPatchelfIgnoreMissingDeps = [ "libpython*" ];
    dontStrip = true;

    installPhase = ''
      mkdir -p $out
      cp -r msp430-gcc-9.3.1.11_linux64/. $out/
      cp -r msp430-gcc-support-files/include $out/include
      for t in gcc g++ c++; do
        wrapProgram $out/bin/msp430-elf-$t --add-flags "-I$out/include -L$out/include"
      done
    '';

    meta = {
      description = "TI MSP430 GCC toolchain (msp430-elf)";
      license = lib.licenses.unfree;
      platforms = [ "x86_64-linux" ];
    };
  };

  # mspdebug's "tilib" driver (MSP-FET, LaunchPad eZ-FET) loads TI's libmsp430.so at run time
  mspdebug = pkgs.symlinkJoin {
    name = "mspdebug-tilib";
    paths = [ pkgs.mspdebug ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/mspdebug \
        --prefix LD_LIBRARY_PATH : ${pkgs.mspds-bin}/lib:${lib.makeLibraryPath [ pkgs.libusb1 pkgs.hidapi ]}
    '';
  };
in {
  environment.systemPackages = [
    msp430-gcc
    mspdebug
  ];
  # Debug probes (LaunchPad eZ-FET, MSP-FET) for the logged-in user, without root
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2047", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0451", TAG+="uaccess"
    # ModemManager (on, with NetworkManager) probes serial ports and can hold
    # the probe's one open; keep it away from the eZ-FET and MSP-FET
    ATTRS{idVendor}=="2047", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{MTP_NO_PROBE}="1"
    ATTRS{idVendor}=="0451", ATTRS{idProduct}=="f432", ENV{ID_MM_DEVICE_IGNORE}="1"
  '';
}
