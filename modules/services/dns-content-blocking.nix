{lib, ...}: {
  networking.nameservers = lib.mkForce [
    "159.69.155.94#wurzn.hagezi.org"
    "2a01:4f8:1c1c:d363::1#wurzn.hagezi.org"
  ];
}
