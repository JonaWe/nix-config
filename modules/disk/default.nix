{
  config,
  lib,
  ...
}: {
  options.myconf.disk = {
    extraDatasets = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Extra datasets that sould be added to the zfs zdata pool";
    };
  };
}
