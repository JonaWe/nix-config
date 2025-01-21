{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./disk
    ./services
  ];
}
