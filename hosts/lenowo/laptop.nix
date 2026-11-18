# Hand-written facts about this laptop (Legion 7 16IAX10).
{ pkgs, ... }: {
  # NVIDIA RTX 50-series: PRIME offload. Intel draws the desktop.
  # The NVIDIA GPU turns off when no program uses it.
  hardware.graphics.enable = true;
  # VA-API hardware video decode on the Intel iGPU (Firefox, mpv)
  hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
  # Hide the NVIDIA Vulkan ICD so Vulkan apps never wake the dGPU (CUDA is unaffected)
  environment.sessionVariables.VK_LOADER_DRIVERS_DISABLE = "nvidia_icd*";
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;                        # required for RTX 50-series
    modesetting.enable = true;
    powerManagement.enable = true;      # saves GPU memory on sleep/hibernate
    powerManagement.finegrained = true; # turns the GPU off when idle
    videoAcceleration = false;          # no NVDEC VA-API driver: video decode stays on Intel
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;  # adds the "nvidia-offload" command
      intelBusId = "PCI:0:2:0";         # 0000:00:02.0
      nvidiaBusId = "PCI:2:0:0";        # 0000:02:00.0
    };
  };

  # Thunderbolt/USB4: approve new devices (docks, drives) from Plasma
  services.hardware.bolt.enable = true;

  # Lenovo conservation mode: stop charging at about 80%
  systemd.tmpfiles.rules = [
    "w /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode - - - - 1"
  ];
}
