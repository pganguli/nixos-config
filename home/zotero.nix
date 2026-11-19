# Zotero preferences, written as user.js into the existing profile
# (~/.zotero/zotero/ppkwhpgo.default). Zotero itself is installed in
# modules/desktop/gui.nix.
#
# Not declared: the library (~/Zotero), the sync password (in the profile's
# logins.json), pane and sidebar layout, and the Better BibTeX extension
# itself (installed by hand into the profile; it updates itself).
{ lib, ... }:
let
  prefs = {
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
  home.file.".zotero/zotero/ppkwhpgo.default/user.js".text = userJs;
}
