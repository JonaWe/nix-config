{
  base-dir,
  device-name,
  ...
}: let
  devices = {
    pangolin = {
      id = "SCRTM6K-4YE5FGZ-HP27RDE-Z4PUUNQ-WUVCGF6-633QWR5-X6XYMPS-V72OFQB";
    };
    phone = {
      id = "NWDFWNP-J265KD5-TG6JSA6-5VWRPIN-PN3IBIW-2TUWQ2D-WCKAZ3Q-ZGQ7LAN";
    };
    homelab = {
      id = "DP6G2PA-QLRCJRJ-SZ644M2-LVX2T47-33KGVYT-2QJXS7N-JFXGNZ5-IIVC5Q5";
    };
  };
in {
  devices = devices;
  folders = let
    device-names = builtins.attrNames devices;
  in {
    "keepass" = {
      id = "keepass";
      label = "Keepass Database";
      path = "${base-dir}/.keepass";
      devices = device-names;
    };
    "vault" = {
      id = "vault";
      label = "Obsidian Vault";
      path = "${base-dir}/vault";
      devices = device-names;
    };
    "wallpapers" = {
      id = "wallpapers";
      label = "Wallpapers";
      path = "${base-dir}/pictures/wallpapers";
      devices = device-names;
    };
  };
}
