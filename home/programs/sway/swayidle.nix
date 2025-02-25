{
  pkgs,
  lib,
  ...
}: {
  # services.swayidle = {
  #   enable = true;
  #   events = [
  #     {
  #       event = "before-sleep";
  #       command = "${lib.getExe pkgs.swaylock} -f";
  #     }
  #     {
  #       event = "lock";
  #       command = "${lib.getExe pkgs.swaylock} -f";
  #     }
  #   ];
  #   timeouts = [
  #     {
  #       timeout = 10;
  #       command = ''${lib.getExe pkgs.libnotify} -t 30000 -- "Screen will lock in 30 seconds"'';
  #     }
  #     {
  #       timeout = 30;
  #       command = "${lib.getExe pkgs.swaylock} -f";
  #     }
  #     {
  #       timeout = 40;
  #       command = ''${pkgs.sway}/bin/swaymsg "output * dpms off"'';
  #       resumeCommand = ''${pkgs.sway}/bin/swaymsg "output * dpms on"'';
  #     }
  #   ];
  # };
}
