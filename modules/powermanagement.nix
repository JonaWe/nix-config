{...}: {
  powerManagement.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;

      # Keep NVMe/SATA drives always on during boot to prevent mount hangs.
      # TLP 1.9+ defaults to aggressive NVMe runtime PM which blocks the
      # vfat /boot mount when applied during udev coldplug.
      AHCI_RUNTIME_PM_ON_AC = "on";
      AHCI_RUNTIME_PM_ON_BAT = "on";

      # Let the kernel manage PCIe ASPM rather than TLP overriding it early boot.
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "default";

      #Optional helps save long term battery health
      # START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
      # STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
    };
  };
}
