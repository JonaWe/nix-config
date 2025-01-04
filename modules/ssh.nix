{...}: {
  services.openssh = {
    enable = true;
    settings = {
      # PasswordAuthentication = false;
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };
  # services.fail2ban.enable = true;
}
