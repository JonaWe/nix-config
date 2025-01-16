{...}: {
  devices = {
    pangolin = {
      id = "SCRTM6K-4YE5FGZ-HP27RDE-Z4PUUNQ-WUVCGF6-633QWR5-X6XYMPS-V72OFQ";
    };
    phone = {
      id = "NWDFWNP-J265KD5-TG6JSA6-5VWRPIN-PN3IBIW-2TUWQ2D-WCKAZ3Q-ZGQ7LAN";
    };
    homelab = {
      id = "DP6G2PA-QLRCJRJ-SZ644M2-LVX2T47-33KGVYT-2QJXS7N-JFXGNZ5-IIVC5Q5";
    };
  };
  folders = {
    "test-folder" = {
      id = "test-folder";
      label = "Test Folder";
      path = "/home/jona/test-folder";
      devices = ["pangolin" "phone" "homelab"];
    };
  };
}
