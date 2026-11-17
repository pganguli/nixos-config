{ ... }: {
  # iwd over wpa_supplicant for all NetworkManager-managed wifi: lighter
  # (no D-Bus wpa_supplicant layer) and snappier to connect/reconnect.
  # Does not affect throughput -- that is the driver/firmware's job, not
  # the supplicant's. iwd's WPA-Enterprise/EAP-TLS support is less
  # battle-tested than wpa_supplicant's, worth keeping in mind on networks
  # like eduroam.
  networking.networkmanager.wifi.backend = "iwd";
}
