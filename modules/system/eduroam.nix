{ pkgs, ... }:
let
  # Run after each SecureW2 enrollment (and after each renewal):
  #   sh SecureW2_JoinNow.run    # as your user
  #   sudo eduroam-iwd
  # SecureW2 leaves NetworkManager a profile whose client certificate and key are
  # a .crt and a .p12. iwd can't read those, so this converts the .p12 to the PEM
  # files iwd can load and points the profile at them.
  eduroam-iwd = pkgs.writeShellApplication {
    name = "eduroam-iwd";
    runtimeInputs = with pkgs; [ networkmanager openssl coreutils ];
    text = ''
      conn=''${1:-eduroam}   # NetworkManager connection name
      dir=/var/lib/iwd/eduroam-certs

      [ "$(id -u)" -eq 0 ] || { echo "run as root: sudo eduroam-iwd" >&2; exit 1; }

      key=$(nmcli -s -g 802-1x.private-key connection show "$conn")
      key=''${key#file://}
      case $key in
        *.p12|*.pfx) ;;
        *) echo "$conn: private key is '$key', not a .p12: nothing to convert" >&2; exit 0 ;;
      esac
      [ -r "$key" ] || { echo "cannot read $key" >&2; exit 1; }

      # The .p12 password is the one NetworkManager saved with the profile
      PW=$(nmcli -s -g 802-1x.private-key-password connection show "$conn")
      [ -n "$PW" ] || { echo "$conn has no saved private-key password" >&2; exit 1; }
      export PW

      umask 077
      install -d -m 700 "$dir"
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
      nmcli connection up "$conn"
    '';
  };
in {
  environment.systemPackages = [ eduroam-iwd ];

  # iwd loads the client key through the kernel keyring, which needs the PKCS#8
  # parser. This kernel builds it as a module that nothing loads by itself;
  # without it iwd logs "Error loading client private key" for a valid key.
  boot.kernelModules = [ "pkcs8_key_parser" ];
}
