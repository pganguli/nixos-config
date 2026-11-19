# Plasma settings, managed with plasma-manager. They are the Plasma version of
# the old i3 + XFCE setup (dotfiles/.config/i3/config and .config/xfce4).
#
# plasma-manager writes keys into the normal Plasma files (kwinrc,
# kglobalshortcutsrc, ...) at login. It changes only the keys listed here
# (overrideConfig is off), so settings that are not here stay as they are.
# Log out and in after a rebuild.
#
# Other files: plasma-panel.nix (top panel), plasma-apps.nix (Dolphin, KIO and
# other KDE apps), mime.nix (default applications).
{ pkgs, lib, ... }:
let
  # Workspaces 1 to 10, as in i3
  workspaces = lib.range 1 10;
  digit = n: toString (lib.mod n 10);   # workspace 10 is on the 0 key

  # What Shift+<digit> is on a US keyboard. KDE sometimes stores the symbol
  # (Meta+!) and not Meta+Shift+1, so both forms are bound.
  shifted = [ ")" "!" "@" "#" "$" "%" "^" "&" "*" "(" ];
  shiftedKey = n: lib.elemAt shifted (lib.mod n 10);

  # i3: Ctrl+Print = select a region, OCR it, put the text in the clipboard
  # (ASCII only, no trailing newline)
  screenshotOcr = pkgs.writeShellApplication {
    name = "screenshot-ocr";
    runtimeInputs = with pkgs; [ kdePackages.spectacle tesseract wl-clipboard coreutils glibc.bin ];
    text = ''
      img=$(mktemp --suffix=.png)
      trap 'rm -f "$img"' EXIT
      spectacle --background --region --nonotify --output "$img" || exit 0
      [ -s "$img" ] || exit 0
      # $(...) removes the trailing newline
      text=$(tesseract "$img" stdout -l eng --psm 6 txt quiet \
        | iconv --from-code=UTF-8 --to-code=ASCII//TRANSLIT -c --silent || true)
      printf '%s' "$text" | wl-copy
    '';
  };
in {
  # Krohnkite: a KWin script that tiles windows automatically, like i3
  home.packages = [ pkgs.kdePackages.krohnkite ];

  programs.plasma = {
    enable = true;

    # ---------- Workspaces ----------
    # i3: ten workspaces, named 1 to 10
    kwin.virtualDesktops = {
      number = 10;
      rows = 1;
      names = map toString workspaces;
    };

    # i3: hsetroot -solid "#000000" (the screen locker is black too)
    workspace = {
      wallpaperPlainColor = "0,0,0";
      colorScheme = "BreezeLight";
      widgetStyle = "Breeze";
      splashScreen = { engine = "none"; theme = "None"; };   # no splash screen
    };
    kscreenlocker = {
      autoLock = true;
      timeout = 10;                # minutes
      lockOnResume = true;         # xfce4-session: lock when waking from sleep
      passwordRequiredDelay = 0;
      appearance.wallpaperPlainColor = "0,0,0";
    };

    # gammastep: 6000 K by day, 4000 K at night, switching around 06:00 and 21:00
    kwin.nightLight = {
      enable = true;
      mode = "times";
      temperature = { day = 6000; night = 4000; };
      time = { morning = "06:00"; evening = "21:00"; };
      transitionTime = 30;
    };

    # ---------- Keyboard and touchpad ----------
    input.keyboard = {
      layouts = [ { layout = "us"; } ];
      numlockOnStartup = "on";   # xfce: Numlock = true
      repeatDelay = 250;         # xfce: 250 ms
      repeatRate = 100;          # xfce had 125; Plasma allows at most 100
    };
    input.touchpads = [
      {
        name = "ELAN06FA:00 04F3:3280 Touchpad";
        vendorId = "04F3";
        productId = "3280";
        naturalScroll = true;        # xfce: ReverseScrolling
        tapToClick = true;
        disableWhileTyping = true;
      }
    ];

    # ---------- Power (the values from xfce4-power-manager) ----------
    powerdevil = {
      general.pausePlayersOnSuspend = true;
      batteryLevels.lowLevel = 15;
      lowBattery.powerProfile = "powerSaving";
      AC = {
        powerProfile = "performance";
        powerButtonAction = "showLogoutScreen";
        whenLaptopLidClosed = "lockScreen";
        whenSleepingEnter = "standbyThenHibernate";   # modules/power.nix: hibernate after 2 h
        autoSuspend.action = "nothing";
        turnOffDisplay.idleTimeout = 300;
      };
      battery = {
        powerProfile = "powerSaving";
        powerButtonAction = "showLogoutScreen";
        whenLaptopLidClosed = "sleep";
        whenSleepingEnter = "standbyThenHibernate";
        autoSuspend = { action = "sleep"; idleTimeout = 300; };
        turnOffDisplay.idleTimeout = 240;
      };
    };

    # ---------- Shortcuts ----------
    # i3: Mod is the Meta (Windows) key.
    shortcuts = {
      kwin = lib.mkMerge [
        {
          # i3: Mod+Shift+q closes the window (Mod+q is no longer used)
          "Window Close" = [ "Meta+Shift+Q" "Alt+F4" ];
          # Meta+F: the window fills the workspace (the panel stays).
          # Meta+Shift+F: real fullscreen, i3's Mod+f.
          "Window Maximize" = "Meta+F";
          "Window Fullscreen" = "Meta+Shift+F";

          # Keys that Krohnkite uses now. Free them in KWin.
          "Switch Window Left" = [ ];
          "Switch Window Right" = [ ];
          "Switch Window Up" = [ ];
          "Switch Window Down" = [ ];
          "Window Pack Left" = [ ];
          "Window Pack Right" = [ ];
          "Window Pack Up" = [ ];
          "Window Pack Down" = [ ];
          "Switch One Desktop to the Left" = [ ];
          "Switch One Desktop to the Right" = [ ];
          "Switch One Desktop Up" = [ ];
          "Switch One Desktop Down" = [ ];
          "Edit Tiles" = [ ];        # KWin's own tiling; Krohnkite replaces it
          "Overview" = [ ];          # Meta+W is the tabbed layout
          "Show Desktop" = [ ];      # Meta+D opens KRunner
          "view_actual_size" = [ ];  # Meta+0 is workspace 10

          # Default keys that were turned off by hand
          "Expose" = [ ];
          "ExposeAll" = [ ];
          "ExposeClass" = [ ];
          "Grid View" = [ ];
          "Kill Window" = [ ];
          "MoveMouseToCenter" = [ ];
          "MoveMouseToFocus" = [ ];
          "Walk Through Windows of Current Application" = [ ];
          "Walk Through Windows of Current Application (Reverse)" = [ ];
          "Window Minimize" = [ ];
          "Window Operations Menu" = [ ];
          "Window One Desktop Down" = [ ];
          "Window One Desktop Up" = [ ];
          "Window One Desktop to the Left" = [ ];
          "Window One Desktop to the Right" = [ ];
          "Window Quick Tile Bottom" = [ ];
          "Window Quick Tile Left" = [ ];
          "Window Quick Tile Right" = [ ];
          "Window Quick Tile Top" = [ ];
          "Window to Next Screen" = [ ];
          "Window to Previous Screen" = [ ];
          "disableInputCapture" = [ ];
          "Activate Window Demanding Attention" = "Meta+Shift+A";

          # i3 focus: Mod+arrows. Move: Mod+Shift+arrows. Resize: Mod+Ctrl+arrows
          # (i3 has a resize mode, Mod+r; KWin has no modes, so resize gets a chord).
          "KrohnkiteFocusLeft" = "Meta+Left";
          "KrohnkiteFocusRight" = "Meta+Right";
          "KrohnkiteFocusUp" = "Meta+Up";
          "KrohnkiteFocusDown" = "Meta+Down";
          "KrohnkiteShiftLeft" = "Meta+Shift+Left";
          "KrohnkiteShiftRight" = "Meta+Shift+Right";
          "KrohnkiteShiftUp" = "Meta+Shift+Up";
          "KrohnkiteShiftDown" = "Meta+Shift+Down";
          "KrohnkiteShrinkWidth" = "Meta+Ctrl+Left";
          "KrohnkitegrowWidth" = "Meta+Ctrl+Right";
          "KrohnkiteShrinkHeight" = "Meta+Ctrl+Up";
          "KrohnkiteGrowHeight" = "Meta+Ctrl+Down";

          # i3: Mod+Shift+space toggles floating
          "KrohnkiteToggleFloat" = "Meta+Shift+Space";
          "KrohnkiteFloatAll" = [ ];

          # i3: Mod+w tabbed, Mod+s stacking, Mod+e toggle split
          "KrohnkiteMonocleLayout" = "Meta+W";     # one window at a time, like tabs
          "KrohnkiteStackedLayout" = "Meta+S";
          "KrohnkiteBTreeLayout" = "Meta+E";       # splits, like i3's default layout
          "KrohnkiteTileLayout" = "Meta+T";
          "KrohnkiteNextLayout" = "Meta+\\";

          # Krohnkite defaults that clash with other keys
          "KrohnkiteSetMaster" = "Meta+Shift+Return";   # Meta+Return is the terminal
          "KrohnkiteDecrease" = [ ];                    # Meta+D is KRunner
          "KrohnkiteFocusNext" = [ ];                   # Meta+. is the emoji picker
          "KrohnkiteFocusPrev" = [ ];
        }
        # i3: Mod+<n> goes to workspace n, Mod+Shift+<n> moves the window there
        (lib.listToAttrs (map (n: lib.nameValuePair "Switch to Desktop ${toString n}" "Meta+${digit n}") workspaces))
        (lib.listToAttrs (map (n: lib.nameValuePair "Window to Desktop ${toString n}"
          [ "Meta+Shift+${digit n}" "Meta+${shiftedKey n}" ]) workspaces))
      ];

      plasmashell = lib.mkMerge [
        # The task manager also wants Meta+1 to Meta+9
        (lib.listToAttrs (map (n: lib.nameValuePair "activate task manager entry ${toString n}" [ ])
          (lib.range 1 9)))
        {
          "manage activities" = [ ];   # Meta+Q: no longer needed
          # Other defaults that were turned off by hand
          "activate application launcher" = [ ];   # the Meta key alone
          "clipboard_action" = [ ];
          "cycle-panels" = [ ];
          "show dashboard" = [ ];
          "show-on-mouse-pos" = [ ];
        }
      ];

      ksmserver."Lock Session" = [ "Meta+L" "Meta+Esc" "Screensaver" ];   # xfce: Super+Esc
      kaccess."Toggle Screen Reader On and Off" = [ ];
      org_kde_powerdevil.powerProfile = "Battery";   # not Meta+B

      # i3 (xfce): Mod+Return starts Alacritty, Mod+d opens the launcher
      "services/Alacritty.desktop"._launch = "Meta+Return";
      "services/org.kde.krunner.desktop" = {
        _launch = "Meta+D";
        RunClipboard = [ ];
      };
      "services/org.kde.plasma-systemmonitor.desktop"._launch = "Ctrl+Shift+Esc";   # xfce: task manager
      "services/org.kde.plasma.emojier.desktop"._launch = "Meta+.";
      "services/org.kde.dolphin.desktop"._launch = [ ];   # Meta+E is the split layout; xfce had no key either
      "services/systemsettings.desktop"._launch = [ ];
    };

    # i3: Print = full screen, Shift+Print = region
    spectacle.shortcuts = {
      captureEntireDesktop = "Print";
      captureRectangularRegion = "Shift+Print";
      recordScreen = "Meta+Print";
      captureActiveWindow = [ ];
      captureCurrentMonitor = [ ];
      captureWindowUnderCursor = [ ];
      launch = [ ];
      launchWithoutCapturing = [ ];
      recordRegion = [ ];
      recordWindow = [ ];
    };

    hotkeys.commands."screenshot-ocr" = {
      name = "Screenshot to text (OCR)";
      key = "Ctrl+Print";
      command = "${screenshotOcr}/bin/screenshot-ocr";
    };

    # ---------- Files ----------
    configFile = {
      # Plasma's default terminal (used by "Terminal=true" apps such as nvim
      # and vifm in the app picker)
      kdeglobals = {
        General = {
          TerminalApplication = "alacritty";
          TerminalService = "Alacritty.desktop";
          UseSystemBell = true;
        };
        KDE = {
          AnimationDurationFactor = 0;   # no animations, as in i3
          ShowDeleteCommand = false;
          contrast = 4;
          frameContrast = 0.2;
        };
        Sounds.Enable = false;
        # Standard application shortcuts that were cleared by hand
        Shortcuts = {
          FullScreen = "";
          Help = "";
          KeyBindings = "";
          OpenContextMenu = "";
          OpenMainMenu = "";
          Preferences = "";
          ShowHideHiddenFiles = "";
          WhatsThis = "";
        };
        "KFileDialog Settings" = {
          "Allow Expansion" = false;
          "Automatically select filename extension" = true;
          "Breadcrumb Navigation" = true;
          "Decoration position" = 2;
          "Show Full Path" = false;
          "Show Inline Previews" = true;
          "Show Preview" = false;
          "Show Speedbar" = true;
          "Show hidden files" = false;
          "Sort by" = "Name";
          "Sort directories first" = true;
          "Sort hidden files last" = false;
          "Sort reversed" = false;
          "Speedbar Width" = 140;
          "View Style" = "DetailTree";
        };
        PreviewSettings = {
          EnableRemoteFolderThumbnail = false;
          MaximumRemoteSize = 0;
        };
      };

      kwinrc = {
        # i3: floating_modifier Mod. Hold Meta and drag with the left button to
        # move a window (with the right button to resize), from anywhere in it.
        MouseBindings.CommandAllKey = "Meta";

        # i3: the focus follows the mouse
        Windows = {
          FocusPolicy = "FocusFollowsMouse";
          NextFocusPrefersMouse = true;
          DelayFocusInterval = 0;
          Placement = "Maximizing";
        };

        Plugins = {
          krohnkiteEnabled = true;
          slideEnabled = false;
          frozenappEnabled = false;
        };

        Script-krohnkite = {
          # The first layout in the order is the default on every workspace.
          # Binary tree splits like i3: drag a window onto the left, right,
          # top or bottom of another one (or onto a screen edge) to split
          # there. Meta+W switches the workspace to tabbed (monocle: every
          # window fills it, one at a time), Meta+E goes back to splits.
          binaryTreeLayoutOrder = 1;
          monocleLayoutOrder = 2;
          tileLayoutOrder = 3;

          # Zoom: all its windows float, but the two main ones tile
          # (the i3 for_window rules). The first line that matches wins.
          floatConfig = lib.concatStringsSep "\n" [
            "zoom,Zoom:Meeting:f=false"
            "zoom,Zoom:Zoom Workplace - Licensed account:f=false"
            "zoom,Zoom:f=true"
          ];
        };
      };
    };
  };

  # Monitors: scale, rotation, position and the layouts for lid open/closed.
  # KWin rewrites this file whenever the displays change, so it is copied as a
  # normal file (not linked) on each switch. To keep a new arrangement, copy
  # ~/.config/kwinoutputconfig.json to home/files/plasma/ in this repo.
  home.activation.plasmaOutputs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run install -m 644 ${./files/plasma/kwinoutputconfig.json} \
      "$HOME/.config/kwinoutputconfig.json"
  '';
}
