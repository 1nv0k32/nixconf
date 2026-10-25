{
  lib,
  pkgs,
  workspaces,
  # Shell-provided niri actions for the keys below; each shell maps them to its own tools.
  actions,
  extra,
}:
let
  empty = _: { };
  spawn = package: args: { spawn = [ (lib.getExe package) ] ++ args; };

  workspaceBinds = lib.mergeAttrsList (
    lib.imap1 (key: name: {
      "Mod+${toString key}".focus-workspace = name;
      "Mod+Shift+${toString key}".move-column-to-workspace = name;
    }) workspaces
  );
in
workspaceBinds
// {
  "Mod+Return" = spawn pkgs.kitty [ ];
  "Mod+Space" = actions.launcher;
  "Mod+E" = spawn pkgs.nautilus [ ];
  "Mod+Escape" = actions.session;
  "Mod+Backspace" = actions.lock;
  "Mod+Shift+S" = actions.suspend;
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

  "Mod+F12" = actions.volumeUp;
  "Mod+F11" = actions.volumeDown;
  "Mod+F10" = actions.mute;
  "Mod+V" = actions.micMute;
  "XF86AudioRaiseVolume" = actions.volumeUp;
  "XF86AudioLowerVolume" = actions.volumeDown;
  "XF86AudioMute" = actions.mute;
  "XF86AudioMicMute" = actions.micMute;
  "XF86MonBrightnessUp" = actions.brightnessUp;
  "XF86MonBrightnessDown" = actions.brightnessDown;

  "Mod+Ctrl+Right" = actions.mediaNext;
  "Mod+Ctrl+Down" = actions.mediaPlayPause;
  "Mod+Ctrl+Left" = actions.mediaPrevious;
  "Mod+Ctrl+Up" = actions.mediaStop;
  "XF86AudioNext" = actions.mediaNext;
  "XF86AudioPlay" = actions.mediaPlayPause;
  "XF86AudioPrev" = actions.mediaPrevious;
  "XF86AudioStop" = actions.mediaStop;
}
// extra
