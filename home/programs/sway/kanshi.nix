{...}: {
  services.kanshi = let
    internal = "eDP-1";
    home_main = "ASUSTek COMPUTER INC VG27AQ1A LALMQS102663";
    home_sec = "BNQ ZOWIE XL LCD N5H01932SL0";
  in {
    enable = true;
    # systemdTarget = "graphical-session.target";
    settings = [
      {
        profile.name = "internal";
        profile.exec = "swww img /home/jona/bg.jpg";
        profile.outputs = [
          {
            criteria = internal;
            status = "enable";
            # adaptiveSync = true;
            # mode = "2560x1440@144";
            scale = 1.0;
            position = "0,0";
          }
        ];
      }
      {
        profile.name = "docked-home";
        profile.exec = "swww img /home/jona/bg.jpg";
        profile.outputs = [
          {
            criteria = home_main;
            status = "enable";
            scale = 1.0;
            adaptiveSync = true;
            mode = "2560x1440@144";
            position = "0,0";
          }
          {
            criteria = home_sec;
            status = "enable";
            scale = 1.0;
            position = "2560,180";
          }
        ];
      }
      {
        profile.name = "docked-home+internal";
        profile.exec = "swww img /home/jona/bg.jpg";
        profile.outputs = [
          {
            criteria = internal;
            status = "enable";
            scale = 1.0;
            position = "320,1440";
          }
          {
            criteria = home_main;
            status = "enable";
            scale = 1.0;
            adaptiveSync = true;
            mode = "2560x1440@144";
            position = "0,0";
          }
          {
            criteria = home_sec;
            status = "enable";
            scale = 1.0;
            position = "2560,180";
          }
        ];
      }
    ];
  };
}
