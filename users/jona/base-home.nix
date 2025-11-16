{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../home/programs/neovim
    ../../home/programs/tmux.nix
  ];

  home.username = "jona";
  home.homeDirectory = "/home/jona";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # here is some command line tools I use frequently
    # feel free to add your own or remove some of them
    neofetch

    # archives
    zip
    # xz
    unzip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    # yq-go # yaml processor https://github.com/mikefarah/yq
    # eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder
    lsd

    # networking tools
    # mtr # A network diagnostic tool
    # iperf3
    dnsutils # `dig` + `nslookup`
    # ldns # replacement of `dig`, it provide the command `drill`
    # aria2 # A lightweight multi-protocol & multi-source command-line download utility
    # socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    # ipcalc # it is a calculator for the IPv4/v6 addresses

    # misc
    # cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    # gnupg
    gnumake

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    # nix-output-monitor

    # productivity
    # hugo # static site generator
    # glow # markdown previewer in terminal

    nethogs #
    btop # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb

    zsh-fzf-tab
    zsh-vi-mode
    # zsh-vi-mode

    tldr
  ];

  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Jona";
    userEmail = "jona.wessendorf1@uni-bielefeld.de";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  programs.starship.enable = true;
  programs.zoxide.enable = true;
  programs.bat.enable = true;
  programs.fd.enable = true;
  programs.ripgrep.enable = true;
  programs.lazygit.enable = true;
  programs.lazydocker.enable = true;
  programs.lsd = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh.enable = true;
    plugins = [
      # {
      #   name = "zsh-vi-mode";
      #   src = "${pkgs.zsh-vi-mode}/share/zsh-vi-mode";
      # }
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];

    shellAliases = {
      v = "nvim";
      nrs = "sudo nixos-rebuild switch --flake /home/jona/nix-config";
      lg = "lazygit";
      lzd = "lazydocker";
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
