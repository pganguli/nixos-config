# MATLAB through nix-matlab (https://gitlab.com/doronbehar/nix-matlab).
# Nix gives the environment; you install MATLAB itself with the MathWorks installer.
# The install folder is set in ~/.config/matlab/nix.sh (see home/pganguli.nix).
{ inputs, pkgs, ... }:
let
  nm = inputs.nix-matlab;

  # nix-matlab's own list of libraries, plus freetype. The MathWorks service
  # host (~/.MathWorks/ServiceHost, outside the MATLAB install) needs
  # libfreetype.so.6 for its web window service. Without it MATLAB shows
  # "Unable to communicate with required MathWorks services (error 5201)".
  targetPkgs = p: (nm.targetPkgs p) ++ [ p.freetype ];

  # Same as nix-matlab's `matlab` package, but built with the list above.
  matlab = pkgs.buildFHSEnv {
    name = "matlab";
    inherit targetPkgs;
    extraInstallCommands = ''
      install -Dm644 ${desktopItem}/share/applications/matlab.desktop $out/share/applications/matlab.desktop
      substituteInPlace $out/share/applications/matlab.desktop \
        --replace-fail "@out@" ${placeholder "out"}
      for s in 64x64 256x256 512x512; do
        install -Dm644 ${nm}/icons/hicolor/$s/matlab.png $out/share/icons/hicolor/$s/apps/matlab.png
      done
    '';
    runScript = pkgs.writeScript "matlab-runner" ''
      # Needed for simulink even on wayland systems
      export QT_QPA_PLATFORM=xcb
      # Where the MathWorks installer put MATLAB (set in ~/.config/matlab/nix.sh)
      if [[ -f ~/.config/matlab/nix.sh ]]; then
        source ~/.config/matlab/nix.sh
      else
        echo "matlab: did not find ~/.config/matlab/nix.sh" >&2
        exit 1
      fi
      if [[ ! -d "$INSTALL_DIR" ]]; then
        echo "matlab: INSTALL_DIR $INSTALL_DIR isn't a directory" >&2
        exit 2
      fi
      # Use the system libstdc++ instead of the older one that MATLAB bundles
      exec env \
        LD_PRELOAD=/lib/libstdc++.so \
        LD_LIBRARY_PATH=/usr/lib/xorg/modules/dri/ \
        $INSTALL_DIR/bin/matlab "$@"
    '';
    meta.description = "MATLAB itself: the GUI launcher";
  };

  desktopItem = pkgs.makeDesktopItem {
    desktopName = "Matlab";
    name = "matlab";
    exec = "@out@/bin/matlab -desktop %F";
    icon = "matlab";
    categories = [ "Utility" "TextEditor" "Development" "IDE" ];
    mimeTypes = [ "text/x-octave" "text/x-matlab" ];
    keywords = [ "science" "math" "matrix" "numerical computation" "plotting" ];
  };
in {
  nixpkgs.overlays = [
    nm.overlay
    (final: prev: { inherit matlab; })
  ];

  environment.systemPackages = with pkgs; [
    matlab        # starts MATLAB (after you install it)
    matlab-shell  # a shell in which the MathWorks installer runs
    matlab-mlint  # code checker
    matlab-mex    # builds MEX files
  ];
}
