{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./jellyfin.nix
    ./teamspeak.nix
    ./disk
  ];
}
