{...}: {
  services.openssh = {
    enable = true;
    settings = {
      # PasswordAuthentication = false;
      PermitRootLogin = "yes";
      PasswordAuthentication = "yes";
    };
  };
  # services.fail2ban.enable = true;
}
