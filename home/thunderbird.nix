# Thunderbird preferences, written as user.js into the existing profile
# (~/.config/thunderbird/0aj7a1dl.default). Thunderbird itself is installed in
# modules/desktop/gui.nix.
#
# Not declared on purpose: the mail accounts, calendars and address books
# (two Gmail accounts, UNC Outlook, their CalDAV and CardDAV links, signatures).
# Home Manager's programs.thunderbird keeps its profile in ~/.thunderbird, not
# in the profile above, and the accounts hold sign-in state and sync tokens.
{ lib, ... }:
let
  prefs = {
    # Reading
    "general.smoothScroll" = false;
    "layout.css.always_underline_links" = true;
    "mail.display_glyph" = false;              # keep :) as text
    "mail.pane_config.dynamic" = 0;
    "mail.uidensity" = 0;
    "mail.threadpane.cardsview.rowcount" = 2;
    "mail.threadpane.listview" = 1;           # table view instead of cards
    "mailnews.default_sort_order" = 1;        # ascending
    "browser.theme.toolbar-theme" = 0;        # dark
    "browser.theme.content-theme" = 0;        # dark
    "mail.shell.checkDefaultClient" = false;  # don't ask to be the default mail client
    "extensions.importexporttoolsng.export.filename_pattern" = "%d-%s-%k";
    "mailnews.start_page.enabled" = false;
    "messenger.options.messagesStyle.theme" = "simple";    # chat
    "messenger.options.messagesStyle.variant" = "Dark";

    # Writing
    "mail.compose.autosaveinterval" = 1;      # minutes
    "mail.compose.big_attachments.notify" = false;
    "mail.compose.big_attachments.threshold_kb" = 25600;

    # Receipts and spam
    "mail.receipt.request_return_receipt_on" = true;
    "mail.incorporate.return_receipt" = 1;
    "mail.mdn.report.not_in_to_cc" = 0;
    "mail.mdn.report.other" = 0;
    "mail.spam.manualMark" = true;
    "mail.phishing.detection.enabled" = false;   # no scam-link warnings

    # No sounds
    "mail.biff.play_sound" = false;
    "mail.chat.play_sound" = false;
    "calendar.alarms.playsound" = false;

    # Privacy
    "network.cookie.cookieBehavior" = 1;      # block third-party cookies
    "privacy.globalprivacycontrol.enabled" = true;
  };
  userJs = lib.concatStringsSep "\n"
    (lib.mapAttrsToList (k: v: "user_pref(${builtins.toJSON k}, ${builtins.toJSON v});") prefs) + "\n";
in {
  xdg.configFile."thunderbird/0aj7a1dl.default/user.js".text = userJs;
}
