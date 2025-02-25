{...}: {
  services.kanshi = let
    out_laptop = "eDP-1";
    out_home_right = "BNQ ZOWIE XL LCD N5H01932SL0";
  in {
    enable = true;
    systemdTarget = "graphical-session.target";
    settings = [
      {
        profile.name = "internal";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            # adaptiveSync = true;
            # mode = "2560x1440@144";
            scale = 1.0;
            position = "0,0";
          }
        ];
      }
      {
        profile.name = "external";
        profile.outputs = [
          {
            criteria = out_laptop;
            status = "enable";
            scale = 1.0;
            position = "0,1080";
          }
          {
            criteria = out_home_right;
            status = "enable";
            scale = 1.0;
            position = "0,0";
          }
        ];
      }
    ];
  };
}
