{...}: {
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "yes";
    };
  };
  # services.fail2ban.enable = true;
}
