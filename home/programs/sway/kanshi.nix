{...}: {
  services.kanshi = let
    internal = "eDP-1";
    home_main = "ASUSTek COMPUTER INC VG27AQ1A LALMQS102663";
    home_sec = "BNQ ZOWIE XL LCD N5H01932SL0";
  in {
    enable = true;
    systemdTarget = "graphical-session.target";
    settings = [
      {
        profile.name = "internal";
        profile.outputs = [
          {
            criteria = internal;
            status = "enable";
            scale = 1.0;
            position = "0,0";
          }
        ];
      }
      {
        profile.name = "docked-home";
        profile.outputs = [
          {
            criteria = home_main;
            status = "enable";
            scale = 1.0;
            adaptiveSync = true;
            mode = "2560x1440@144";
            position = "1920,0";
          }
          {
            criteria = home_sec;
            status = "enable";
            scale = 1.0;
            position = "0,0";
          }
        ];
      }
      {
        profile.name = "docked-home+internal";
        profile.outputs = [
          {
            criteria = internal;
            status = "enable";
            scale = 1.0;
            mode = "1920x1200@60";
            position = "1920,1440";
          }
          {
            criteria = home_main;
            status = "enable";
            scale = 1.0;
            adaptiveSync = true;
            mode = "2560x1440@144";
            position = "1920,0";
          }
          {
            criteria = home_sec;
            status = "enable";
            scale = 1.0;
            mode = "1920x1080@60";
            position = "0,0";
            # transform = "90";
          }
        ];
      }
      {
        profile.name = "docked-home-second";
        profile.outputs = [
          {
            criteria = internal;
            status = "enable";
            scale = 1.0;
            position = "0,1080";
          }
          {
            criteria = home_sec;
            status = "enable";
            scale = 1.0;
            position = "0,0";
          }
        ];
      }
    ];
  };
}
