{...}: {
  xdg = {
    configFile = {
      "mimeapps.list".force = true;
    };
    mimeApps = let
      discord = "discord.desktop";
      # gimp = "gimp.desktop";
      imv = "imv.desktop";
      # inkscape = "org.inkscape.Inkscape.desktop";
      # krita = "krita_psd.desktop";
      vlc = "vlc.desktop";
      neovim = "nvim.desktop";
      pcmanfm = "pcmanfm.desktop";
      # qutebrowser = "org.qutebrowser.qutebrowser.desktop";
      bravebrowser = "brave-browser.desktop";
      zathura = "org.pwmt.zathura.desktop";
      telegram = "org.telegram.desktop.desktop";
    in rec {
      enable = true;
      defaultApplications = {
        "application/pdf" = [zathura];
        "application/vnd.ms-publisher" = [neovim];
        "application/x-extension-htm" = [bravebrowser];
        "application/x-extension-html" = [bravebrowser];
        "application/x-extension-shtml" = [bravebrowser];
        "application/x-extension-xht" = [bravebrowser];
        "application/x-extension-xhtml" = [bravebrowser];
        "application/xhtml+xml" = [bravebrowser];
        "application/xml" = [neovim];
        "audio/aac" = [vlc];
        "audio/flac" = [vlc];
        "audio/mp4" = [vlc];
        "audio/mpeg" = [vlc];
        "audio/ogg" = [vlc];
        "audio/x-wav" = [vlc];
        "image/gif" = [imv];
        "image/jpeg" = [imv];
        "image/png" = [imv];
        # "image/svg+xml" = [inkscape];
        # "image/vnd.adobe.photoshop" = [krita];
        "image/webp" = [imv];
        # "image/x-eps" = [inkscape];
        # "image/x-xcf" = [gimp];
        "inode/directory" = [pcmanfm];
        "text/html" = [bravebrowser];
        "text/markdown" = [neovim];
        "text/plain" = [neovim];
        "text/uri-list" = [bravebrowser];
        "video/mp4" = [vlc];
        "video/ogg" = [vlc];
        "video/webm" = [vlc];
        "video/x-flv" = [vlc];
        "video/x-matroska" = [vlc];
        "video/x-ms-wmv" = [vlc];
        "video/x-ogm+ogg" = [vlc];
        "video/x-theora+ogg" = [vlc];
        "x-scheme-handler/about" = [bravebrowser];
        "x-scheme-handler/chrome" = [bravebrowser];
        "x-scheme-handler/discord" = [discord];
        "x-scheme-handler/ftp" = [bravebrowser];
        "x-scheme-handler/http" = [bravebrowser];
        "x-scheme-handler/https" = [bravebrowser];
        "x-scheme-handler/unknown" = [bravebrowser];
        "x-scheme-handler/tg" = telegram;
        "x-scheme-handler/tonsite" = telegram;
      };
      associations.added = defaultApplications;
    };
  };
}
