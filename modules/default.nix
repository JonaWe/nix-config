{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./jellyfin.nix
  ];
}
