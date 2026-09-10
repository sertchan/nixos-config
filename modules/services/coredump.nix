{
  systemd = {
    coredump.settings.Coredump = {
      Storage = "none";
      ProcessSizeMax = 0;
    };

    tmpfiles.settings."coredump-privacy"."/var/lib/systemd/coredump/*".R = {};
  };
}
