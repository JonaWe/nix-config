{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./jellyfin.nix
    ./teamspeak.nix
    ./syncthing.nix
    ./disk
  ];
}
