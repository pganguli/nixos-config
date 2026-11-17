# MATLAB through nix-matlab (https://gitlab.com/doronbehar/nix-matlab).
# Nix gives the environment; you install MATLAB itself with the MathWorks installer.
# The install folder is set in ~/.config/matlab/nix.sh (see home/pganguli.nix).
{ inputs, pkgs, ... }: {
  nixpkgs.overlays = [ inputs.nix-matlab.overlay ];

  environment.systemPackages = with pkgs; [
    matlab        # starts MATLAB (after you install it)
    matlab-shell  # a shell in which the MathWorks installer runs
    matlab-mlint  # code checker
    matlab-mex    # builds MEX files
  ];
}
