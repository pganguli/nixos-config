{ pkgs, ... }:
let
  # Run after each SecureW2 enrollment (and after each renewal):
  #   sh SecureW2_JoinNow.run    # as your user
  #   sudo eduroam-iwd
  # SecureW2 leaves NetworkManager a profile whose client certificate and key are
  # a .crt and a .p12. iwd can't read those, so this converts the .p12 to the PEM
  # files iwd can load and points the profile at them. It also sets UNC's root CA
  # (unc-root3.pem, SHA-256 CE:11:ED:C0:...:91:BD:21, from the SecureW2 enrollment)
  # so the RADIUS server's certificate chain is checked.
  eduroam-iwd = pkgs.writeShellApplication {
    name = "eduroam-iwd";
    runtimeInputs = with pkgs; [ networkmanager openssl coreutils ];
    text = ''
      dir=/var/lib/iwd/eduroam-certs

      [ "$(id -u)" -eq 0 ] || { echo "run as root: sudo eduroam-iwd" >&2; exit 1; }

      # The enrollment script may name the profile "eduroam [<uuid prefix>]", so
      # without an argument use the one wifi profile with SSID eduroam. An
      # argument (name or UUID) overrides this.
      conn=''${1:-}
      if [ -z "$conn" ]; then
        found=()
        while IFS=: read -r uuid type; do
          [ "$type" = 802-11-wireless ] || continue
          [ "$(nmcli -g 802-11-wireless.ssid connection show uuid "$uuid")" = eduroam ] && found+=("$uuid")
        done < <(nmcli -t -f UUID,TYPE connection show)
        case ''${#found[@]} in
          0) echo "no wifi profile for SSID eduroam" >&2; exit 1 ;;
          1) conn=''${found[0]} ;;
          *) echo "several eduroam profiles: ''${found[*]}" >&2
             echo "delete the old ones (nmcli connection delete uuid <uuid>) or pass one" >&2; exit 1 ;;
        esac
      fi
      # conn is a UUID (auto-detected) or a name given as an argument; try both
      nm() { nmcli "$@" connection show uuid "$conn" 2>/dev/null || nmcli "$@" connection show id "$conn"; }

      umask 077
      install -d -m 700 "$dir"

      # 1. Client certificate and key. Only while the profile still points at the
      #    .p12 (fresh enrollment); afterwards they are already converted.
      key=$(nm -s -g 802-1x.private-key)
      key=''${key#file://}
      case $key in
        *.p12|*.pfx)
          [ -r "$key" ] || { echo "cannot read $key" >&2; exit 1; }
          # The .p12 password is the one NetworkManager saved with the profile
          PW=$(nm -s -g 802-1x.private-key-password)
          [ -n "$PW" ] || { echo "$conn has no saved private-key password" >&2; exit 1; }
          export PW
          # x509/pkey drop the "Bag Attributes" text that pkcs12 writes before the PEM.
          openssl pkcs12 -in "$key" -passin env:PW -clcerts -nokeys \
            | openssl x509 -out "$dir/client.pem.new"
          # iwd rejects a passphrase on an unencrypted key, and NetworkManager writes
          # the saved password into the iwd profile as the key passphrase. So the key
          # is encrypted with that same password (PBES2, AES-256-CBC, PBKDF2-SHA256).
          openssl pkcs12 -in "$key" -passin env:PW -nocerts -nodes \
            | openssl pkey \
            | openssl pkcs8 -topk8 -v2 aes-256-cbc -v2prf hmacWithSHA256 \
                -passout env:PW -out "$dir/client.key.new"
          mv "$dir/client.pem.new" "$dir/client.pem"
          mv "$dir/client.key.new" "$dir/client.key"
          nmcli connection modify "$conn" \
            802-1x.client-cert "$dir/client.pem" \
            802-1x.private-key "$dir/client.key" \
            802-1x.private-key-password "$PW"
          ;;
        *) echo "$conn: key is already converted ($key)" ;;
      esac

      # 2. Server check: UNC's root CA (the server's chain is Root3 > Sub3 >
      #    radius-network.net.unc.edu). No domain match: with
      #    EAP-TLS-ServerDomainMask=radius-network.net.unc.edu iwd rejected the
      #    server ("TLS: Tunnel has disconnected with alert: bad_certificate")
      #    and accepted it without the line, probably because that name isn't a
      #    subjectAltName of the server cert (not checked). So the mask is cleared.
      install -m 644 ${./unc-root3.pem} "$dir/ca.pem"
      nmcli connection modify "$conn" \
        802-1x.ca-cert "$dir/ca.pem" \
        802-1x.domain-suffix-match ""

      # As root, "up" can fail with "Secrets were required, but not provided"
      # (no secret agent); the profile is saved either way, so don't stop here.
      nmcli connection up "$conn" || echo "nmcli up failed: connect from the network applet, or: iwctl station <dev> connect eduroam" >&2
      echo "--- /var/lib/iwd/eduroam.8021x (passphrase hidden):"
      sed 's/^\(EAP-TLS-ClientKeyPassphrase=\).*/\1[hidden]/' /var/lib/iwd/eduroam.8021x
    '';
  };
in {
  environment.systemPackages = [ eduroam-iwd ];

  # iwd loads the client key through the kernel keyring, which needs the PKCS#8
  # parser. This kernel builds it as a module that nothing loads by itself;
  # without it iwd logs "Error loading client private key" for a valid key.
  boot.kernelModules = [ "pkcs8_key_parser" ];
}
