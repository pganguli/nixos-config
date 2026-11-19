# Zotero preferences, written as user.js into the existing profile
# (~/.zotero/zotero/ppkwhpgo.default). Zotero itself is installed in
# modules/desktop/gui.nix.
#
# Not declared: the library (~/Zotero), the sync password (in the profile's
# logins.json), and pane and sidebar layout.
{ lib, pkgs, ... }:
let
  profile = ".zotero/zotero/ppkwhpgo.default";

  # Better BibTeX. This pinned copy is only put in place when the profile has
  # none (a new profile or machine); Better BibTeX then updates itself, so a
  # newer version in the profile is never replaced. Bump this when you like.
  betterBibtex = pkgs.fetchurl {
    url = "https://github.com/retorquere/zotero-better-bibtex/releases/download/v9.0.77/zotero-better-bibtex-9.0.77.xpi";
    hash = "sha256-pfHSuvj/QshXYbej2PZ5n/wwbwgugCTVuDzoDoWSvQs=";
  };

  prefs = {
    # Zotero keeps Firefox's default of disabling add-ons that are found in the
    # profile and not yet registered. 0 lets the Better BibTeX copy above load
    # in a new profile without asking.
    "extensions.autoDisableScopes" = 0;

    "extensions.zotero.dataDir" = "/home/pganguli/Zotero";
    "extensions.zotero.useDataDir" = true;
    "extensions.zotero.sync.server.username" = "prateek-ganguli";
    "extensions.zotero.httpServer.localAPI.enabled" = true;   # local API, for scripts and tools

    "extensions.zotero.export.citePaperJournalArticleURL" = true;
    "extensions.zotero.export.quickCopy.setting" = "export=9cb70025-a888-4a29-a210-93ec52da40d4";

    # Better BibTeX
    "extensions.zotero.translators.better-bibtex.citekeyFormat" = "auth.lower + shorttitle(3, 3) + year";
    "extensions.zotero.translators.better-bibtex.citekeyFormatEditing" = "auth.lower + shorttitle(3, 3) + year";
    "extensions.zotero.translators.better-bibtex.fillKeyAfter" = 1;
    "extensions.zotero.translators.better-bibtex.path.git" = "/etc/profiles/per-user/pganguli/bin/git";
  };
  userJs = lib.concatStringsSep "\n"
    (lib.mapAttrsToList (k: v: "user_pref(${builtins.toJSON k}, ${builtins.toJSON v});") prefs) + "\n";
in {
  home.file."${profile}/user.js".text = userJs;

  home.activation.zoteroBetterBibtex = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    xpi="$HOME/${profile}/extensions/better-bibtex@iris-advies.com.xpi"
    if [ ! -e "$xpi" ]; then
      run install -D -m 644 ${betterBibtex} "$xpi"
    fi
  '';
}
