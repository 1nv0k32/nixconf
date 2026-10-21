{ ... }:
{
  services.logind.settings.Login =
    let
      defaultAction = "lock";
    in
    {
      KillUserProcesses = true;
      IdleAction = "ignore";
      IdleActionSec = 3600;
      HandlePowerKey = defaultAction;
      HandlePowerKeyLongPress = defaultAction;
      HandleRebootKey = defaultAction;
      HandleRebootKeyLongPress = defaultAction;
      HandleSuspendKey = defaultAction;
      HandleSuspendKeyLongPress = defaultAction;
      HandleHibernateKey = defaultAction;
      HandleHibernateKeyLongPress = defaultAction;
      HandleLidSwitch = defaultAction;
      HandleLidSwitchExternalPower = defaultAction;
      HandleLidSwitchDocked = defaultAction;
      HandleSecureAttentionKey = defaultAction;
    };
}
