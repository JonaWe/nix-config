{...}: {
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      # PermitRootLogin = "yes";
      PermitRootLogin = "prohibit-password";
      # PasswordAuthentication = true;
    };
    extraConfig = ''
      Match user git
        AllowTcpForwarding no
        AllowAgentForwarding no
        PasswordAuthentication no
        PermitTTY no
        X11Forwarding no
    '';
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOJLRsOWHhKvbKZVd+TQWJ3zk8zGc8MSNboYBk4/bSF1 jona@me.de"
  ];
  services.fail2ban = {
    enable = false;
    ignoreIP = ["192.168.188.0/24"];
  };
}
