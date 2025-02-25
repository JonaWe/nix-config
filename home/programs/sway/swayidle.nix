{
  pkgs,
  lib,
  ...
}: {
  services.swayidle = {
    enable = true;
    events = [
      {
        event = "before-sleep";
        command = "${lib.getExe pkgs.swaylock} -f";
      }
      {
        event = "lock";
        command = "${lib.getExe pkgs.swaylock} -f";
      }
    ];
  };
}
