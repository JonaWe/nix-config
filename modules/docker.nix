{username, ...}: {
  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = ["${username}"];
}
