{
  lib,
  pkgs,
  shell,
}:
let
  empty = _: { };
  spawn = package: args: { spawn = [ (lib.getExe package) ] ++ args; };
  volume = action: spawn shell.volume [ action ];
  brightness = action: spawn shell.brightness [ action ];
  player = action: spawn pkgs.playerctl [ action ];

  workspaces = lib.mergeAttrsList (
    lib.imap1 (key: name: {
      "Mod+${toString key}".focus-workspace = name;
      "Mod+Shift+${toString key}".move-column-to-workspace = name;
    }) shell.workspaces
  );
in
workspaces
// {
  "Mod+Return" = spawn pkgs.kitty [ ];
  "Mod+Space" = spawn shell.launcher [ ];
  "Mod+E" = spawn pkgs.nautilus [ ];
  "Mod+Escape" = spawn shell.sessionMenu [ ];
  "Mod+Backspace" = spawn shell.lock [ ];
  "Mod+Shift+S" = spawn shell.suspend [ ];
  "Mod+Q".close-window = empty;
  "Mod+Tab".toggle-overview = empty;
  "Mod+Shift+Tab".switch-focus-between-floating-and-tiling = empty;
  "Mod+Shift+Slash".show-hotkey-overlay = empty;

  "Mod+F".maximize-column = empty;
  "Mod+G".fullscreen-window = empty;
  "Mod+Shift+F".toggle-window-floating = empty;
  "Mod+C".center-column = empty;
  "Mod+R".switch-preset-column-width = empty;
  "Mod+Shift+R".reset-window-height = empty;
  "Mod+W".toggle-column-tabbed-display = empty;
  "Mod+BracketLeft".consume-or-expel-window-left = empty;
  "Mod+BracketRight".consume-or-expel-window-right = empty;

  # Vim directions: left, down, up, right.
  "Mod+H".focus-column-left = empty;
  "Mod+J".focus-window-down = empty;
  "Mod+K".focus-window-up = empty;
  "Mod+L".focus-column-right = empty;

  # Shift moves the focused window or column in the same direction.
  "Mod+Shift+H".move-column-left = empty;
  "Mod+Shift+J".move-window-down = empty;
  "Mod+Shift+K".move-window-up = empty;
  "Mod+Shift+L".move-column-right = empty;

  # Ctrl resizes: grow right/down, shrink left/up.
  "Mod+Ctrl+H".set-column-width = "-5%";
  "Mod+Ctrl+J".set-window-height = "+5%";
  "Mod+Ctrl+K".set-window-height = "-5%";
  "Mod+Ctrl+L".set-column-width = "+5%";

  # Vim paging: U/D changes workspace; Shift sends the column.
  "Mod+U".focus-workspace-up = empty;
  "Mod+D".focus-workspace-down = empty;
  "Mod+Shift+U".move-column-to-workspace-up = empty;
  "Mod+Shift+D".move-column-to-workspace-down = empty;

  # Previous/next monitor; Shift sends the column.
  "Mod+Ctrl+P".focus-monitor-previous = empty;
  "Mod+Ctrl+N".focus-monitor-next = empty;
  "Mod+Ctrl+Shift+P".move-column-to-monitor-previous = empty;
  "Mod+Ctrl+Shift+N".move-column-to-monitor-next = empty;

  # Native screenshots support selection and copy directly to the clipboard.
  "Print".screenshot = empty;
  "Mod+Print".screenshot-screen = empty;
  "Mod+Shift+Print".screenshot-window = empty;

  "Mod+F12" = volume "up";
  "Mod+F11" = volume "down";
  "Mod+F10" = volume "mute";
  "Mod+V" = volume "mic-mute";
  "XF86AudioRaiseVolume" = volume "up";
  "XF86AudioLowerVolume" = volume "down";
  "XF86AudioMute" = volume "mute";
  "XF86AudioMicMute" = volume "mic-mute";
  "XF86MonBrightnessUp" = brightness "up";
  "XF86MonBrightnessDown" = brightness "down";

  "Mod+Ctrl+Right" = player "next";
  "Mod+Ctrl+Down" = player "play-pause";
  "Mod+Ctrl+Left" = player "previous";
  "Mod+Ctrl+Up" = player "stop";
  "XF86AudioNext" = player "next";
  "XF86AudioPlay" = player "play-pause";
  "XF86AudioPrev" = player "previous";
  "XF86AudioStop" = player "stop";
}
