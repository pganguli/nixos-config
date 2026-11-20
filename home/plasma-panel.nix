# The top panel, as it was set up by hand: launcher, workspace pager, task
# list, CPU and memory bars, system tray and a clock.
#
# plasma-manager rebuilds the panels at login (when this file changes) and
# deletes plasma-org.kde.plasma.desktop-appletsrc for that. The old file is
# copied to plasma-org.kde.plasma.desktop-appletsrc.pre-plasma-manager once.
#
# Not possible here: the settings of the applets inside the system tray.
# After the first login, set the weather location (Chapel Hill) and "Show
# percentage" for the battery by hand, once.
{ lib, ... }:
let
  cpuAndMemory = name: title: sensor: others: {
    name = "org.kde.plasma.systemmonitor.${name}";
    config = {
      Appearance = {
        chartFace = "org.kde.ksysguard.barchart";
        inherit title;
        updateRateLimit = 3000;
      };
      SensorColors.${sensor} = "61,174,233";
      Sensors = {
        highPrioritySensorIds = ''["${sensor}"]'';
        lowPrioritySensorIds = builtins.toJSON others;
        totalSensors = if name == "cpu"
          then ''["${sensor}"]''
          else ''["memory/physical/usedPercent"]'';
      };
    };
  };
in {
  home.activation.backupPlasmaPanel = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    f="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
    if [ -f "$f" ] && [ ! -e "$f.pre-plasma-manager" ]; then
      run cp "$f" "$f.pre-plasma-manager"
    fi
  '';

  programs.plasma.panels = [
    {
      location = "top";
      height = 32;
      floating = true;
      opacity = "opaque";
      lengthMode = "fill";
      screen = 0;
      widgets = [
        "org.kde.plasma.kickoff"
        # Shows the 10 workspaces, like i3bar. These are the values the live
        # panel already has (plasma-manager's defaults), pinned here.
        {
          name = "org.kde.plasma.pager";
          config.General = {
            currentDesktopSelected = "ShowDesktop";
            displayedText = "Number";
            showOnlyCurrentScreen = true;
            showWindowIcons = true;
          };
        }

        # Tasks sorted by horizontal window position (value 6): the order of
        # the buttons follows the order of the tiles from left to right.
        # Not grouped, no pinned launchers.
        {
          name = "org.kde.plasma.icontasks";
          config.General = {
            groupingStrategy = 0;
            iconSpacing = 0;
            launchers = "";
            sortingStrategy = 6;
          };
        }

        "org.kde.plasma.marginsseparator"

        {
          systemTray.items.extra = [
            "org.kde.plasma.cameraindicator"
            "org.kde.plasma.clipboard"
            "org.kde.plasma.devicenotifier"
            "org.kde.plasma.manage-inputmethod"
            "org.kde.plasma.mediacontroller"
            "org.kde.plasma.notifications"
            "org.kde.kscreen"
            "org.kde.plasma.battery"
            "org.kde.plasma.brightness"
            "org.kde.plasma.keyboardindicator"
            "org.kde.plasma.keyboardlayout"
            "org.kde.plasma.networkmanagement"
            "org.kde.plasma.printmanager"
            "org.kde.plasma.volume"
            "org.kde.plasma.weather"
            "org.kde.plasma.bluetooth"
          ];
        }

        (cpuAndMemory "cpu" "Total CPU Use" "cpu/all/usage"
          [ "cpu/all/cpuCount" "cpu/all/coreCount" ])
        (cpuAndMemory "memory" "Memory Usage" "memory/physical/used"
          [ "memory/physical/total" ])

        {
          name = "org.kde.plasma.digitalclock";
          config.Appearance = {
            dateFormat = "custom";
            customDateFormat = "ddd MMM-d-yyyy | ";   # KDE stored this as "|\s", a space
            dateDisplayFormat = "BesideTime";
            showWeekNumbers = true;
            use24hFormat = 2;
            autoFontAndSize = true;   # system font, scaled to fill the panel
          };
        }
      ];
    }
  ];
}
