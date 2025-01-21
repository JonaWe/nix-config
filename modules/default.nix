{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./jellyfin.nix
    ./disk
  ];
}
